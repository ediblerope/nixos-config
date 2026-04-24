# services/crowdsec.nix — Community-driven IDS/IPS for the mediaserver.
#
# Removes cleanly: delete this file + its import from common.nix, then
# on the server: `sudo rm -rf /var/lib/crowdsec /etc/crowdsec` after a
# final rebuild.
#
# Before first deploy, create /var/secrets/ntfy-url with your ntfy topic URL:
#   echo 'https://ntfy.sh/nordhammer-<random>' | sudo tee /var/secrets/ntfy-url
#   sudo chmod 640 /var/secrets/ntfy-url
# Then subscribe to the same URL in the ntfy Android/iOS app.
{ config, lib, ... }:
let
  ntfyUrlFile = "/var/secrets/ntfy-url";
  ntfyUrl =
    if builtins.pathExists ntfyUrlFile
    then lib.removeSuffix "\n" (builtins.readFile ntfyUrlFile)
    else "https://ntfy.sh/CHANGE-ME-CREATE-VAR-SECRETS-NTFY-URL";
in
{
  config = lib.mkIf (config.networking.hostName == "FredOS-Mediaserver") {

    services.crowdsec = {
      enable = true;

      # Hub collections — parsers + scenarios, pulled from the community hub.
      hub.collections = [
        "crowdsecurity/linux"                 # sshd + linux privilege escalation
        "crowdsecurity/nginx"                 # nginx log parser
        "crowdsecurity/base-http-scenarios"   # generic HTTP attack patterns
        "crowdsecurity/http-cve"              # known-CVE fingerprints
        "crowdsecurity/whitelist-good-actors" # don't ban legit crawlers
      ];

      localConfig = {
        # Log sources to ingest. Labels drive which parsers apply.
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

        # Push phone notifications via ntfy.sh.
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

        # Override the default profile to attach the ntfy notifier.
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

    # Enforce CrowdSec decisions at the firewall level via nftables.
    services.crowdsec-firewall-bouncer = {
      enable = true;
      registerBouncer.enable = true;
    };
  };
}
