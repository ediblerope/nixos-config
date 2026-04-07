{ config, lib, pkgs, ... }:
{
  config = lib.mkIf (config.networking.hostName == "FredOS-Mediaserver") {

    services.homepage-dashboard = {
      enable = true;
      openFirewall = true;
      listenPort = 8082;

      # Allow access from anywhere on the LAN
      # Add your domain here too if you expose it via Nginx Proxy Manager
      allowedHosts = "localhost:8082,127.0.0.1:8082,192.168.4.74:8082";

      # API keys loaded from a file that lives outside the Nix store
      # Create /etc/homepage-secrets with content like:
      #   HOMEPAGE_VAR_JELLYFIN_KEY=your_api_key_here
      #   HOMEPAGE_VAR_SONARR_KEY=your_api_key_here
      #   HOMEPAGE_VAR_RADARR_KEY=your_api_key_here
      #   HOMEPAGE_VAR_PROWLARR_KEY=your_api_key_here
      #   HOMEPAGE_VAR_BAZARR_KEY=your_api_key_here
      #   HOMEPAGE_VAR_QBIT_PASSWORD=your_password_here
      environmentFiles = [ "/etc/homepage-secrets" ];

      settings = {
        title = "FredOS Mediaserver";
        theme = "dark";
        color = "slate";
        headerStyle = "clean";
        layout = {
          Media = { style = "row"; columns = 2; };
          Downloads = { style = "row"; columns = 2; };
          Infrastructure = { style = "row"; columns = 3; };
        };
      };

      widgets = [
        {
          resources = {
            cpu = true;
            memory = true;
            disk = "/";
            label = "System";
          };
        }
        {
          search = {
            provider = "duckduckgo";
            target = "_blank";
          };
        }
        {
          datetime = {
            text_size = "xl";
            format = {
              timeStyle = "short";
              dateStyle = "short";
              hour12 = false;
            };
          };
        }
      ];

      services = [
        {
          Media = [
            {
              Jellyfin = {
                href = "http://192.168.4.74:8096";
                description = "Media server";
                icon = "jellyfin.png";
                widget = {
                  type = "jellyfin";
                  url = "http://192.168.4.74:8096";
                  key = "{{HOMEPAGE_VAR_JELLYFIN_KEY}}";
                  enableBlocks = true;
                  enableNowPlaying = true;
                };
              };
            }
            {
              Bazarr = {
                href = "http://192.168.4.74:6767";
                description = "Subtitle management";
                icon = "bazarr.png";
                widget = {
                  type = "bazarr";
                  url = "http://192.168.4.74:6767";
                  key = "{{HOMEPAGE_VAR_BAZARR_KEY}}";
                };
              };
            }
            {
              Sonarr = {
                href = "http://192.168.4.74:8989";
                description = "TV show management";
                icon = "sonarr.png";
                widget = {
                  type = "sonarr";
                  url = "http://192.168.4.74:8989";
                  key = "{{HOMEPAGE_VAR_SONARR_KEY}}";
                  enableQueue = true;
                };
              };
            }
            {
              Radarr = {
                href = "http://192.168.4.74:7878";
                description = "Movie management";
                icon = "radarr.png";
                widget = {
                  type = "radarr";
                  url = "http://192.168.4.74:7878";
                  key = "{{HOMEPAGE_VAR_RADARR_KEY}}";
                  enableQueue = true;
                };
              };
            }
          ];
        }
        {
          Downloads = [
            {
              qBittorrent = {
                href = "http://192.168.4.74:8080";
                description = "Torrent client";
                icon = "qbittorrent.png";
                widget = {
                  type = "qbittorrent";
                  url = "http://192.168.4.74:8080";
                  username = "admin";
                  password = "{{HOMEPAGE_VAR_QBIT_PASSWORD}}";
                };
              };
            }
            {
              Prowlarr = {
                href = "http://192.168.4.74:9696";
                description = "Indexer manager";
                icon = "prowlarr.png";
                widget = {
                  type = "prowlarr";
                  url = "http://192.168.4.74:9696";
                  key = "{{HOMEPAGE_VAR_PROWLARR_KEY}}";
                };
              };
            }
          ];
        }
        {
          Infrastructure = [
            {
              "Nginx Proxy Manager" = {
                href = "http://192.168.4.74:81";
                description = "Reverse proxy";
                icon = "nginx-proxy-manager.png";
              };
            }
            {
              Authelia = {
                href = "http://192.168.4.74:9091";
                description = "SSO & 2FA";
                icon = "authelia.png";
              };
            }
            {
              go2rtc = {
                href = "http://192.168.4.74:1984";
                description = "Camera streams";
                icon = "go2rtc.png";
              };
            }
          ];
        }
      ];
    };

  };
}
