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

        # SSH brute force — uses built-in sshd filter via journald
        sshd = {
          settings = {
            enabled = true;
            filter = "sshd";
            maxretry = 5;
            bantime = "1h";
          };
        };

        # Nginx Proxy Manager — watches Docker-mounted log files
        # Catches repeated 401/403 responses (auth failures, bad requests)
        nginx-proxy-manager = {
          settings = {
            enabled = true;
            filter = "nginx-http-auth";
            logpath = "/home/fred/docker/nginx-proxy-manager/data/logs/*.log";
            maxretry = 10;
            bantime = "1h";
          };
        };

        # Jellyfin auth failures — uses journald backend
        jellyfin = {
          settings = {
            enabled = true;
            backend = "systemd";
            journalmatch = "_SYSTEMD_UNIT=jellyfin.service";
            maxretry = 5;
            bantime = "2h";
          };
        };

      };
    };

    # Custom Jellyfin filter — matches failed auth log lines from the journal
    environment.etc."fail2ban/filter.d/jellyfin.conf".text = ''
      [Definition]
      failregex = ^.*Authentication request for .* has been denied \(IP: "<HOST>"\).*$
                  ^.*Error processing request from remote IP Address <HOST>.*$
      ignoreregex =
    '';

  };
}
