{ config, lib, pkgs, ... }:
let
  # Script that extracts API keys from all services and writes /etc/homepage-secrets
  extractSecrets = pkgs.writeShellScript "extract-homepage-secrets" ''
    set -euo pipefail

    SECRETS_FILE="/etc/homepage-secrets"

    # --- *arr apps: API keys live in config.xml as <ApiKey>...</ApiKey> ---
    extract_arr_key() {
      local name="$1" path="$2"
      if [ -f "$path" ]; then
        ${pkgs.gnused}/bin/sed -n 's/.*<ApiKey>\(.*\)<\/ApiKey>.*/\1/p' "$path"
      fi
    }

    SONARR_KEY=$(extract_arr_key "sonarr" "/var/lib/sonarr/config.xml")
    RADARR_KEY=$(extract_arr_key "radarr" "/var/lib/radarr/config.xml")
    PROWLARR_KEY=$(extract_arr_key "prowlarr" "/var/lib/prowlarr/config.xml")

    # --- Bazarr: API key in config.ini under [auth] section ---
    BAZARR_KEY=""
    if [ -f "/var/lib/bazarr/data/config/config.ini" ]; then
      BAZARR_KEY=$(${pkgs.gnugrep}/bin/grep -oP '(?<=apikey = ).*' /var/lib/bazarr/data/config/config.ini || true)
    fi
    # Fallback: Bazarr sometimes stores it in config.yaml
    if [ -z "$BAZARR_KEY" ] && [ -f "/var/lib/bazarr/config/config.yaml" ]; then
      BAZARR_KEY=$(${pkgs.gnugrep}/bin/grep -oP '(?<=apikey: ).*' /var/lib/bazarr/config/config.yaml || true)
    fi

    # --- Jellyfin: create an API key in the DB if one doesn't exist ---
    JELLYFIN_KEY=""
    JELLYFIN_DB="/var/lib/jellyfin/data/jellyfin.db"
    if [ -f "$JELLYFIN_DB" ]; then
      # Check if a "Homepage" key already exists
      JELLYFIN_KEY=$(${pkgs.sqlite}/bin/sqlite3 "$JELLYFIN_DB" \
        "SELECT AccessToken FROM ApiKeys WHERE Name = 'Homepage' LIMIT 1;" 2>/dev/null || true)

      if [ -z "$JELLYFIN_KEY" ]; then
        # Generate a random 32-char hex token
        JELLYFIN_KEY=$(${pkgs.coreutils}/bin/head -c 16 /dev/urandom | ${pkgs.coreutils}/bin/od -An -tx1 | ${pkgs.gnused}/bin/sed 's/ //g' | ${pkgs.coreutils}/bin/head -c 32)
        NOW=$(${pkgs.coreutils}/bin/date -u '+%Y-%m-%d %H:%M:%S')
        ${pkgs.sqlite}/bin/sqlite3 "$JELLYFIN_DB" \
          "INSERT INTO ApiKeys (DateCreated, DateLastActivity, Name, AccessToken) VALUES ('$NOW', '0001-01-01 00:01:00', 'Homepage', '$JELLYFIN_KEY');"
      fi
    fi

    # --- Write the secrets file ---
    cat > "$SECRETS_FILE" <<EOF
    HOMEPAGE_VAR_SONARR_KEY=$SONARR_KEY
    HOMEPAGE_VAR_RADARR_KEY=$RADARR_KEY
    HOMEPAGE_VAR_PROWLARR_KEY=$PROWLARR_KEY
    HOMEPAGE_VAR_BAZARR_KEY=$BAZARR_KEY
    HOMEPAGE_VAR_JELLYFIN_KEY=$JELLYFIN_KEY
    EOF

    chmod 600 "$SECRETS_FILE"
  '';
in
{
  config = lib.mkIf (config.networking.hostName == "FredOS-Mediaserver") {

    # Writable location for matugen-generated custom.css; bind-mounted into
    # the homepage service namespace over the Nix-managed /etc path.
    systemd.tmpfiles.rules = [
      "d /var/lib/homepage-custom-css 0755 fred users -"
      "f /var/lib/homepage-custom-css/custom.css 0644 fred users -"
      "d /var/lib/homepage-updates 0755 fred users -"
    ];

    systemd.services.homepage-dashboard.serviceConfig.BindPaths = [
      "/var/lib/homepage-custom-css/custom.css:/etc/homepage-dashboard/custom.css"
    ];

    # Auto-restart homepage when matugen rewrites the custom.css
    systemd.paths.homepage-css-reload = {
      description = "Watch matugen custom.css for changes";
      wantedBy = [ "multi-user.target" ];
      pathConfig.PathChanged = "/var/lib/homepage-custom-css/custom.css";
    };

    systemd.services.homepage-css-reload = {
      description = "Restart homepage after custom.css changes";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.systemd}/bin/systemctl restart homepage-dashboard.service";
      };
    };

    # Oneshot service that extracts API keys and writes /etc/homepage-secrets
    systemd.services.homepage-extract-secrets = {
      description = "Extract API keys for Homepage dashboard";
      after = [
        "jellyfin.service"
        "sonarr.service"
        "radarr.service"
        "bazarr.service"
        "prowlarr.service"
      ];
      requires = [ "jellyfin.service" ];
      before = [ "homepage-dashboard.service" ];
      requiredBy = [ "homepage-dashboard.service" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = extractSecrets;
        RemainAfterExit = true;
      };
    };

    services.homepage-dashboard = {
      enable = true;
      openFirewall = true;
      listenPort = 8082;

      # Allow access from anywhere on the LAN
      # Add your domain here too if you expose it via Nginx Proxy Manager
      allowedHosts = "localhost:8082,127.0.0.1:8082,homepage.nordhammer.it";

      # API keys auto-extracted by homepage-extract-secrets.service
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
                href = "https://jellyfin.nordhammer.it";
                description = "Media server";
                icon = "jellyfin.png";
                widget = {
                  type = "jellyfin";
                  url = "http://127.0.0.1:8096";
                  key = "{{HOMEPAGE_VAR_JELLYFIN_KEY}}";
                  enableBlocks = true;
                  enableNowPlaying = true;
                };
              };
            }
            {
              Bazarr = {
                href = "https://bazarr.nordhammer.it";
                description = "Subtitle management";
                icon = "bazarr.png";
                widget = {
                  type = "bazarr";
                  url = "http://127.0.0.1:6767";
                  key = "{{HOMEPAGE_VAR_BAZARR_KEY}}";
                };
              };
            }
            {
              Sonarr = {
                href = "https://sonarr.nordhammer.it";
                description = "TV show management";
                icon = "sonarr.png";
                widget = {
                  type = "sonarr";
                  url = "http://127.0.0.1:8989";
                  key = "{{HOMEPAGE_VAR_SONARR_KEY}}";
                  enableQueue = true;
                };
              };
            }
            {
              Radarr = {
                href = "https://radarr.nordhammer.it";
                description = "Movie management";
                icon = "radarr.png";
                widget = {
                  type = "radarr";
                  url = "http://127.0.0.1:7878";
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
                href = "https://torrent.nordhammer.it";
                description = "Torrent client";
                icon = "qbittorrent.png";
                widget = {
                  type = "qbittorrent";
                  url = "http://127.0.0.1:8080";
                };
              };
            }
            {
              Prowlarr = {
                href = "https://prowlarr.nordhammer.it";
                description = "Indexer manager";
                icon = "prowlarr.png";
                widget = {
                  type = "prowlarr";
                  url = "http://127.0.0.1:9696";
                  key = "{{HOMEPAGE_VAR_PROWLARR_KEY}}";
                };
              };
            }
          ];
        }
        {
          Infrastructure = [
            {
              Authelia = {
                href = "https://auth.nordhammer.it";
                description = "SSO & 2FA";
                icon = "authelia.png";
              };
            }
            {
              go2rtc = {
                href = "https://camera.nordhammer.it";
                description = "Camera streams";
                icon = "go2rtc.png";
              };
            }
            {
              "Last Update" = {
                description = "Most recent nixos-rebuild switch";
                icon = "mdi-history";
                widget = {
                  type = "customapi";
                  url = "http://127.0.0.1:8083/latest.json";
                  refreshInterval = 60000;
                  method = "GET";
                  display = "list";
                  mappings = [
                    { field = "date";    label = "Date"; }
                    { field = "changes"; label = "Changes"; }
                    { field = "closure"; label = "Closure"; }
                    { field = "kernel";  label = "Kernel"; }
                  ];
                };
              };
            }
          ];
        }
      ];
    };

  };
}
