# services/adguard.nix — AdGuard Home network-wide DNS ad blocker
{ config, lib, pkgs, ... }:
{
  config = lib.mkIf (config.networking.hostName == "FredOS-Mediaserver") {

    services.adguardhome = {
      enable = true;
      # Web UI bound to localhost; nginx reverse-proxies at adguard.nordhammer.it
      host = "127.0.0.1";
      port = 3000;
      # Nix is authoritative: settings below overwrite UI-made changes on rebuild
      mutableSettings = false;
      settings = {
        dns = {
          bind_hosts = [ "0.0.0.0" ];
          port = 53;
          # Query all upstreams in parallel; take the fastest response
          upstream_mode = "parallel";
          # Mix of DoH (encrypted) and plain UDP (low-latency) upstreams
          upstream_dns = [
            "https://dns.cloudflare.com/dns-query"
            "https://dns.quad9.net/dns-query"
            "1.1.1.1"
            "9.9.9.9"
          ];
          bootstrap_dns = [ "1.1.1.1" "9.9.9.9" ];
          cache_size = 4194304;
          cache_ttl_min = 60;
        };
        filters = [
          { enabled = true; id = 1; name = "AdGuard DNS filter";
            url = "https://adguardteam.github.io/AdGuardSDNSFilter/Filters/filter.txt"; }
          { enabled = true; id = 2; name = "AdAway Default Blocklist";
            url = "https://adaway.org/hosts.txt"; }
          { enabled = true; id = 3; name = "OISD Big";
            url = "https://big.oisd.nl/"; }
        ];
        # Resolve our own hostnames to the router's LAN IP so LAN clients
        # bypass any NAT reflection.
        filtering.rewrites = [
          { domain = "nordhammer.it";   answer = "10.0.0.1"; }
          { domain = "*.nordhammer.it"; answer = "10.0.0.1"; }
        ];
      };
    };

    # LAN DNS — router blocks WAN:53 so this is effectively LAN-only
    networking.firewall.allowedTCPPorts = [ 53 ];
    networking.firewall.allowedUDPPorts = [ 53 ];
  };
}
