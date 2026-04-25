# services/router.nix — mediaserver acts as the home router
#
# Layout:
#   eno1 = WAN (DHCP from ISP; in phase 1, from the eero still in router mode)
#   eth0 = LAN (static 10.0.0.1/24, serves DHCP to downstream clients)
#
# Services on this box:
#   - systemd-networkd: interface management (replaces NetworkManager here)
#   - nftables: NAT (masquerade out WAN) + firewall (drop WAN inbound except ports.toml)
#   - dnsmasq: DHCP only (port 0 for DNS — AdGuard Home owns :53)
#   - AdGuard Home (already running): DNS for LAN clients
#
# Port forwards live in ../ports.toml so they're easy to edit.

{ config, lib, pkgs, ... }:
let
  portsData = builtins.fromTOML (builtins.readFile ../ports.toml);
  destDefault = portsData.dest_default;

  # Phase-1 transition list; empty now that eero is in bridge mode and
  # eno1 is strictly the ISP-facing WAN.
  trustedLegacyCidrs = [ ];

  legacyTrustRules = lib.concatMapStringsSep "\n            "
    (cidr: ''iifname "eno1" ip saddr ${cidr} accept'')
    trustedLegacyCidrs;

  # Expand "both" into [tcp, udp]; normalise port vs ports; default dest.
  expandForward = entry:
    let
      protos = if entry.protocol == "both" then [ "tcp" "udp" ] else [ entry.protocol ];
      portExpr =
        if entry ? port  then toString entry.port
        else if entry ? ports then builtins.replaceStrings [ "-" ] [ "-" ] entry.ports
        else throw "ports.toml entry '${entry.name}' has neither 'port' nor 'ports'";
      dest = entry.dest or destDefault;
    in
      map (p: { inherit (entry) name; proto = p; port = portExpr; dest = dest; }) protos;

  forwards = lib.concatMap expandForward portsData.forward;

  # nftables accepts port-range literals like "26901-26902" as-is.
  dnatRules = lib.concatMapStringsSep "\n        "
    (f: ''${f.proto} dport ${f.port} dnat to ${f.dest} comment "${f.name}"'')
    forwards;

  # Input-chain accept rules so WAN traffic to forwarded ports reaches the
  # mediaserver. Works in both phases:
  #   phase 1: eero DNATs to 192.168.4.25, arrives on eno1 — matched here.
  #   phase 2: our DNAT rewrites dst to 10.0.0.1 (local), arrives on eno1 — matched here.
  wanPortInputRules = lib.concatMapStringsSep "\n            "
    (f: ''iifname "eno1" ${f.proto} dport ${f.port} accept comment "${f.name}"'')
    forwards;

in
{
  config = lib.mkIf (config.networking.hostName == "FredOS-Mediaserver") {

    # --- Networking stack: systemd-networkd owns the router NICs ---
    networking.networkmanager.enable = lib.mkForce false;
    networking.useNetworkd = true;
    services.resolved.enable = false;   # AdGuard Home binds :53

    # Disable the scripted firewall — nftables takes over below.
    networking.firewall.enable = false;

    # IP forwarding is required for routing.
    boot.kernel.sysctl = {
      "net.ipv4.ip_forward" = 1;
      "net.ipv4.conf.all.rp_filter" = 1;
      "net.ipv6.conf.all.forwarding" = 0;  # no IPv6 upstream yet
    };

    # --- Interface configuration ---
    systemd.network = {
      enable = true;
      networks = {
        "10-wan" = {
          matchConfig.Name = "eno1";
          networkConfig = {
            DHCP = "ipv4";
            IPv6AcceptRA = false;
          };
          dhcpV4Config = {
            UseDNS = false;      # don't overwrite resolv.conf from ISP DNS
            UseHostname = false;
          };
        };
        "20-lan" = {
          matchConfig.Name = "eth0";
          networkConfig = {
            Address = "10.0.0.1/24";
            ConfigureWithoutCarrier = true;
            IPv6AcceptRA = false;
          };
          linkConfig.RequiredForOnline = "no";
        };
      };
    };

    # --- nftables: NAT + firewall ---
    networking.nftables = {
      enable = true;
      tables.filter = {
        family = "inet";
        content = ''
          chain input {
            type filter hook input priority 0; policy drop;
            ct state established,related accept
            ct state invalid drop
            iifname "lo" accept
            # LAN is trusted
            iifname "eth0" accept
            # Phase 1: also trust the existing eero subnet on eno1 so SSH
            # and AdGuard DNS keep working during the transition.
            ${legacyTrustRules}
            # Accept WAN traffic for ports we publicly expose (ports.toml).
            ${wanPortInputRules}
            # ICMP from anywhere (ping, path-MTU)
            icmp type echo-request accept
            icmpv6 type echo-request accept
          }
          chain forward {
            type filter hook forward priority 0; policy drop;
            ct state established,related accept
            ct state invalid drop
            # LAN → anywhere
            iifname "eth0" accept
            # Docker containers → anywhere (needed for image pulls, LinuxGSM bootstrap, etc.)
            iifname "docker0" accept
            # WAN → LAN only if it was DNAT'd by a port-forward rule
            iifname "eno1" oifname "eth0" ct status dnat accept
          }
          chain output {
            type filter hook output priority 0; policy accept;
          }
        '';
      };
      tables.nat = {
        family = "ip";
        content = ''
          chain prerouting {
            type nat hook prerouting priority -100; policy accept;
            iifname "eno1" jump port_forwards
          }
          chain port_forwards {
            ${dnatRules}
          }
          chain postrouting {
            type nat hook postrouting priority 100; policy accept;
            oifname "eno1" masquerade
          }
        '';
      };
    };

    # --- DHCP server on the LAN ---
    services.dnsmasq = {
      enable = true;
      settings = {
        interface = "eth0";
        bind-interfaces = true;
        # AdGuard Home owns DNS; dnsmasq only does DHCP.
        port = 0;
        dhcp-range = [ "10.0.0.100,10.0.0.250,12h" ];
        dhcp-option = [
          "option:router,10.0.0.1"
          "option:dns-server,10.0.0.1"
        ];
        # Static reservations — format: "MAC,label,IP"
        dhcp-host = [
          "f0:a7:31:6c:50:4b,camera-bedroom,10.0.0.39"
        ];
        # Helpful: log leases to the journal
        log-dhcp = true;
      };
    };

  };
}
