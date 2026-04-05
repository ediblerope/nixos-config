{ config, lib, ... }:
{
  config = lib.mkIf (config.networking.hostName == "FredOS-Mediaserver") {
    services.crowdsec = {
      enable = true;
      autoUpdateService = true;

      localConfig.acquisitions = [
        # SSH
        {
          source = "journalctl";
          journalctl_filter = [ "-u" "sshd" ];
          labels.type = "syslog";
        }
        # Nginx Proxy Manager (Docker logs via journald)
        {
          source = "journalctl";
          journalctl_filter = [ "-u" "docker" "-t" "nginx-proxy-manager" ];
          labels.type = "nginx";
        }
      ];
    };

    # Firewall bouncer — auto-registers to local CrowdSec API
    services.crowdsec-firewall-bouncer = {
      enable = true;
      settings.api_url = "http://127.0.0.1:8080";
    };
  };
}
