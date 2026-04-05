{ config, lib, pkgs, ... }:
{
  config = lib.mkIf (config.networking.hostName == "FredOS-Mediaserver") {
    services.crowdsec = {
      enable = true;
      autoUpdateService = true;

      # Install detection collections on first boot
      hub.collections = [ "crowdsecurity/linux" "crowdsecurity/sshd" ];

      settings = {
        # Enable the Local API server (required for bouncer registration)
        general.api.server.enable = true;
        # Where the LAPI client credentials will be written on first boot
        lapi.credentialsFile = "/var/lib/crowdsec/state/lapi-credentials.yaml";
      };

      localConfig.acquisitions = [
        # SSH brute-force detection
        {
          source = "journalctl";
          journalctl_filter = [ "-u" "sshd" ];
          labels.type = "syslog";
        }
      ];
    };

    # The bouncer-register service uses raw cscli (no -c flag), so it looks for
    # config at /etc/crowdsec/config.yaml. Symlink the Nix-generated config there.
    systemd.tmpfiles.rules = [
      "L+ /etc/crowdsec/config.yaml - - - - ${(pkgs.formats.yaml { }).generate "crowdsec.yaml" config.services.crowdsec.settings.general}"
    ];

    # Firewall bouncer — auto-registers to local CrowdSec LAPI
    services.crowdsec-firewall-bouncer = {
      enable = true;
      settings.api_url = "http://127.0.0.1:8080";
    };
  };
}
