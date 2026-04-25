# services/crowdsec.nix — Vendors the crowdsec module rewrite from
# https://github.com/NixOS/nixpkgs/pull/446307 (TornaxO7's branch) until
# it lands upstream. The upstream module in nixpkgs at the pinned revision
# is broken for first-time bootstrap (no auto cscli machines add, DynamicUser
# state ownership wedges).
#
# When PR #446307 merges to nixpkgs unstable:
#   1. Bump flake.lock past the merge commit
#   2. Delete ../modules/crowdsec/ and the disabledModules + imports lines below
#   3. The settings/option API is the same as the PR's, so config below is forward-compatible
#
# Before first deploy, create /var/secrets/ntfy-url with your topic URL:
#   echo 'https://ntfy.sh/nordhammer-<random>' | sudo tee /var/secrets/ntfy-url
#   sudo chmod 640 /var/secrets/ntfy-url
{ config, lib, pkgs, ... }:
let
  ntfyUrlFile = "/var/secrets/ntfy-url";
  ntfyUrl =
    if builtins.pathExists ntfyUrlFile
    then lib.removeSuffix "\n" (builtins.readFile ntfyUrlFile)
    else "https://ntfy.sh/CHANGE-ME-CREATE-VAR-SECRETS-NTFY-URL";

  # nixpkgs only builds the agent + cscli; the new module also expects
  # notification plugins at $out/libexec/crowdsec/plugins/. Compile them
  # from the same source tree (cmd/notification-*) and move them there.
  pluginNames = [ "dummy" "email" "file" "http" "sentinel" "slack" "splunk" ];
  crowdsecWithPlugins = pkgs.crowdsec.overrideAttrs (old: {
    subPackages = (old.subPackages or [ ]) ++ map (p: "cmd/notification-${p}") pluginNames;
    postInstall = (old.postInstall or "") + ''
      mkdir -p $out/libexec/crowdsec/plugins
      for p in ${lib.concatStringsSep " " pluginNames}; do
        if [ -f $out/bin/notification-$p ]; then
          mv $out/bin/notification-$p $out/libexec/crowdsec/plugins/notification-$p
        fi
      done
    '';
  });
in
{
  disabledModules = [
    "services/security/crowdsec.nix"
    "services/security/crowdsec-firewall-bouncer.nix"
  ];

  imports = [
    ../modules/crowdsec/crowdsec.nix
    ../modules/crowdsec/crowdsec-firewall-bouncer.nix
  ];

  config = lib.mkIf (config.networking.hostName == "FredOS-Mediaserver") {

    services.crowdsec = {
      enable = true;
      name = "fredos-mediaserver";
      package = crowdsecWithPlugins;

      hub.collections = [
        "crowdsecurity/linux"                 # sshd + linux LPE
        "crowdsecurity/nginx"                 # nginx parser
        "crowdsecurity/base-http-scenarios"   # generic HTTP attacks
        "crowdsecurity/http-cve"              # known-CVE fingerprints
        "crowdsecurity/whitelist-good-actors" # don't ban legit crawlers
      ];

      # Allow the agent (DynamicUser) to read its acquisition sources:
      #  - nginx group → /var/log/nginx/access.log (nginx:nginx 640)
      #  - systemd-journal → journald entries from sshd + authelia
      #    (without it, journalctl returns "insufficient permissions" and
      #    the entire ssh-bf / authelia-bf detection chain runs blind)
      readOnlyPaths = [ "/var/log/nginx" ];
      extraGroups = [ "nginx" "systemd-journal" ];

      settings = {
        # config.yaml — main agent + LAPI configuration
        config.api.server.listen_uri = "127.0.0.1:8081";  # 8080 is qBit

        # Log sources to ingest
        acquisitions = [
          {
            source = "file";
            filenames = [ "/var/log/nginx/access.log" ];
            labels.type = "nginx";
          }
          {
            source = "journalctl";
            journalctl_filter = [ "_SYSTEMD_UNIT=sshd.service" ];
            labels.type = "syslog";
          }
          {
            source = "journalctl";
            journalctl_filter = [ "_SYSTEMD_UNIT=authelia-main.service" ];
            labels.type = "syslog";
          }
        ];

        # Push notifications via ntfy.sh
        notifications = [
          {
            name = "ntfy_http";
            type = "http";
            log_level = "info";
            url = ntfyUrl;
            method = "POST";
            headers = {
              Title = "CrowdSec alert";
              Priority = "high";
              Tags = "rotating_light";
            };
            format = ''
              {{range . -}}
              {{.Scenario}} from {{.Source.IP}} ({{.Source.Cn}}) — {{len .Decisions}} decision(s) taken
              {{end -}}
            '';
          }
        ];

        # Override default profiles to attach the ntfy notifier
        profiles = [
          {
            name = "default_ip_remediation";
            filters = [ "Alert.Remediation == true && Alert.GetScope() == 'Ip'" ];
            decisions = [{ type = "ban"; duration = "4h"; }];
            notifications = [ "ntfy_http" ];
            on_success = "break";
          }
          {
            name = "default_range_remediation";
            filters = [ "Alert.Remediation == true && Alert.GetScope() == 'Range'" ];
            decisions = [{ type = "ban"; duration = "4h"; }];
            notifications = [ "ntfy_http" ];
            on_success = "break";
          }
        ];
      };
    };

    # Firewall bouncer enforces decisions via nftables; auto-registers with LAPI
    services.crowdsec-firewall-bouncer = {
      enable = true;
      registerBouncer.enable = true;
    };
  };
}
