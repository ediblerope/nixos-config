{ config, lib, pkgs, ... }:
{
  config = lib.mkIf (config.networking.hostName == "FredOS-Mediaserver") {

    services.fail2ban = {
      enable = true;

      # Default ban settings (overridable per jail)
      maxretry = 5;
      bantime = "1h";

      # Progressively longer bans for repeat offenders, up to 1 week
      bantime-increment = {
        enable = true;
        multiplier = "1 2 4 8 16 32 64";
        maxtime = "168h";
        overalljails = true;
      };

      # Never ban local network traffic
      ignoreIP = [
        "127.0.0.1/8"
        "::1"
        "192.168.0.0/16"
        "10.0.0.0/8"
      ];

      jails = {

        # SSH brute force — built-in sshd filter via journald
        sshd = {
          settings = {
            enabled = true;
            filter = "sshd";
            maxretry = 5;
            bantime = "1h";
          };
        };

        # Nginx Proxy Manager — watches Docker-mounted log files for 401/403s
        nginx-proxy-manager = {
          settings = {
            enabled = true;
            filter = "nginx-http-auth";
            logpath = "/home/fred/docker/nginx-proxy-manager/data/logs/*.log";
            maxretry = 10;
            bantime = "1h";
          };
        };

        # Jellyfin auth failures — journald
        jellyfin = {
          settings = {
            enabled = true;
            backend = "systemd";
            journalmatch = "_SYSTEMD_UNIT=jellyfin.service";
            maxretry = 5;
            bantime = "2h";
          };
        };

        # Sonarr — log files at dataDir/logs/
        sonarr = {
          settings = {
            enabled = true;
            filter = "arr-apps";
            logpath = "/var/lib/sonarr/logs/*.txt";
            maxretry = 5;
            bantime = "1h";
          };
        };

        # Radarr — log files at dataDir/logs/
        radarr = {
          settings = {
            enabled = true;
            filter = "arr-apps";
            logpath = "/var/lib/radarr/logs/*.txt";
            maxretry = 5;
            bantime = "1h";
          };
        };

        # Prowlarr — log files at dataDir/logs/
        prowlarr = {
          settings = {
            enabled = true;
            filter = "arr-apps";
            logpath = "/var/lib/prowlarr/logs/*.txt";
            maxretry = 5;
            bantime = "1h";
          };
        };

        # Bazarr — log files at dataDir/log/
        bazarr = {
          settings = {
            enabled = true;
            filter = "bazarr";
            logpath = "/var/lib/bazarr/log/*.txt";
            maxretry = 5;
            bantime = "1h";
          };
        };

        # qBittorrent-nox — watches journald for web UI login failures
        qbittorrent = {
          settings = {
            enabled = true;
            filter = "qbittorrent";
            backend = "systemd";
            journalmatch = "_SYSTEMD_UNIT=qbittorrent-nox.service";
            maxretry = 5;
            bantime = "1h";
          };
        };

      };
    };

    # Shared filter for Sonarr, Radarr, Prowlarr — they all use the same *arr codebase
    environment.etc."fail2ban/filter.d/arr-apps.conf".text = ''
      [Definition]
      failregex = .*Auth-Failure ip <HOST>
      ignoreregex =
    '';

    # Bazarr (Python/Flask) auth failure filter
    environment.etc."fail2ban/filter.d/bazarr.conf".text = ''
      [Definition]
      failregex = .*login attempt.*<HOST>
                  .*unauthorized.*<HOST>
      ignoreregex =
    '';

    # qBittorrent web UI login failure filter
    environment.etc."fail2ban/filter.d/qbittorrent.conf".text = ''
      [Definition]
      failregex = .*WebAPI login failure.*remote IP: <HOST>
      ignoreregex =
    '';

    # Jellyfin filter
    environment.etc."fail2ban/filter.d/jellyfin.conf".text = ''
      [Definition]
      failregex = ^.*Authentication request for .* has been denied \(IP: "<HOST>"\).*$
                  ^.*Error processing request from remote IP Address <HOST>.*$
      ignoreregex =
    '';

  };
}
