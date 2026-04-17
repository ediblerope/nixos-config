{ config, lib, pkgs, ... }:
let
  interconnectScript = pkgs.writeShellScript "arr-interconnect" ''
    set -euo pipefail
    PATH="${lib.makeBinPath [ pkgs.curl pkgs.jq pkgs.gnused pkgs.gnugrep pkgs.coreutils ]}:$PATH"

    BASE="http://127.0.0.1"

    # --- Extract API keys ---
    extract_arr_key() {
      if [ -f "$1" ]; then
        sed -n 's/.*<ApiKey>\(.*\)<\/ApiKey>.*/\1/p' "$1"
      fi
    }

    SONARR_KEY=$(extract_arr_key "/var/lib/sonarr/config.xml")
    RADARR_KEY=$(extract_arr_key "/var/lib/radarr/config.xml")
    PROWLARR_KEY=$(extract_arr_key "/var/lib/prowlarr/config.xml")

    BAZARR_KEY=""
    if [ -f "/var/lib/bazarr/data/config/config.ini" ]; then
      BAZARR_KEY=$(grep -oP '(?<=apikey = ).*' /var/lib/bazarr/data/config/config.ini || true)
    fi

    # --- Helpers ---
    wait_for() {
      local name="$1" url="$2" key="$3"
      echo "Waiting for $name..."
      for i in $(seq 1 30); do
        if curl -sf -o /dev/null -H "X-Api-Key: $key" "$url"; then
          echo "$name is ready"
          return 0
        fi
        sleep 2
      done
      echo "WARNING: $name not ready after 60s, skipping"
      return 1
    }

    exists_by_name() {
      local url="$1" key="$2" name="$3"
      local count
      count=$(curl -sf -H "X-Api-Key: $key" "$url" | jq --arg n "$name" '[.[] | select(.name == $n)] | length')
      [ "$count" -gt "0" ]
    }

    # --- Wait for services ---
    wait_for "Sonarr"   "$BASE:8989/api/v3/system/status" "$SONARR_KEY"   || true
    wait_for "Radarr"   "$BASE:7878/api/v3/system/status" "$RADARR_KEY"   || true
    wait_for "Prowlarr" "$BASE:9696/api/v1/system/status" "$PROWLARR_KEY" || true

    ##########################################################################
    # Prowlarr → Sonarr (push indexers for TV)
    ##########################################################################
    if [ -n "$PROWLARR_KEY" ] && [ -n "$SONARR_KEY" ]; then
      if ! exists_by_name "$BASE:9696/api/v1/applications" "$PROWLARR_KEY" "Sonarr"; then
        echo "Adding Sonarr to Prowlarr..."
        curl -sf -X POST \
          -H "Content-Type: application/json" \
          -H "X-Api-Key: $PROWLARR_KEY" \
          "$BASE:9696/api/v1/applications" \
          -d "$(jq -n --arg key "$SONARR_KEY" '{
            name: "Sonarr",
            syncLevel: "fullSync",
            implementation: "Sonarr",
            configContract: "SonarrSettings",
            implementationName: "Sonarr",
            fields: [
              {name: "prowlarrUrl", value: "http://localhost:9696"},
              {name: "baseUrl", value: "http://localhost:8989"},
              {name: "apiKey", value: $key},
              {name: "syncCategories", value: [5000,5010,5020,5030,5040,5045,5050,5060,5070,5080]}
            ],
            tags: []
          }')" > /dev/null && echo "  done" || echo "  failed"
      else
        echo "Prowlarr → Sonarr already configured"
      fi
    fi

    ##########################################################################
    # Prowlarr → Radarr (push indexers for movies)
    ##########################################################################
    if [ -n "$PROWLARR_KEY" ] && [ -n "$RADARR_KEY" ]; then
      if ! exists_by_name "$BASE:9696/api/v1/applications" "$PROWLARR_KEY" "Radarr"; then
        echo "Adding Radarr to Prowlarr..."
        curl -sf -X POST \
          -H "Content-Type: application/json" \
          -H "X-Api-Key: $PROWLARR_KEY" \
          "$BASE:9696/api/v1/applications" \
          -d "$(jq -n --arg key "$RADARR_KEY" '{
            name: "Radarr",
            syncLevel: "fullSync",
            implementation: "Radarr",
            configContract: "RadarrSettings",
            implementationName: "Radarr",
            fields: [
              {name: "prowlarrUrl", value: "http://localhost:9696"},
              {name: "baseUrl", value: "http://localhost:7878"},
              {name: "apiKey", value: $key},
              {name: "syncCategories", value: [2000,2010,2020,2030,2040,2045,2050,2060,2070,2080]}
            ],
            tags: []
          }')" > /dev/null && echo "  done" || echo "  failed"
      else
        echo "Prowlarr → Radarr already configured"
      fi
    fi

    ##########################################################################
    # Sonarr → qBittorrent (download client for TV)
    ##########################################################################
    if [ -n "$SONARR_KEY" ]; then
      if ! exists_by_name "$BASE:8989/api/v3/downloadclient" "$SONARR_KEY" "qBittorrent"; then
        echo "Adding qBittorrent to Sonarr..."
        curl -sf -X POST \
          -H "Content-Type: application/json" \
          -H "X-Api-Key: $SONARR_KEY" \
          "$BASE:8989/api/v3/downloadclient" \
          -d '{
            "enable": true,
            "protocol": "torrent",
            "priority": 1,
            "removeCompletedDownloads": false,
            "removeFailedDownloads": true,
            "name": "qBittorrent",
            "implementation": "QBittorrent",
            "configContract": "QBittorrentSettings",
            "implementationName": "qBittorrent",
            "fields": [
              {"name": "host", "value": "localhost"},
              {"name": "port", "value": 8080},
              {"name": "useSsl", "value": false},
              {"name": "urlBase", "value": ""},
              {"name": "username", "value": ""},
              {"name": "password", "value": ""},
              {"name": "category", "value": "tv-sonarr"},
              {"name": "recentPriority", "value": 0},
              {"name": "olderPriority", "value": 0},
              {"name": "initialState", "value": 0},
              {"name": "sequentialOrder", "value": false},
              {"name": "firstAndLastFirst", "value": false}
            ],
            "tags": []
          }' > /dev/null && echo "  done" || echo "  failed"
      else
        echo "Sonarr → qBittorrent already configured"
      fi
    fi

    ##########################################################################
    # Radarr → qBittorrent (download client for movies)
    ##########################################################################
    if [ -n "$RADARR_KEY" ]; then
      if ! exists_by_name "$BASE:7878/api/v3/downloadclient" "$RADARR_KEY" "qBittorrent"; then
        echo "Adding qBittorrent to Radarr..."
        curl -sf -X POST \
          -H "Content-Type: application/json" \
          -H "X-Api-Key: $RADARR_KEY" \
          "$BASE:7878/api/v3/downloadclient" \
          -d '{
            "enable": true,
            "protocol": "torrent",
            "priority": 1,
            "removeCompletedDownloads": false,
            "removeFailedDownloads": true,
            "name": "qBittorrent",
            "implementation": "QBittorrent",
            "configContract": "QBittorrentSettings",
            "implementationName": "qBittorrent",
            "fields": [
              {"name": "host", "value": "localhost"},
              {"name": "port", "value": 8080},
              {"name": "useSsl", "value": false},
              {"name": "urlBase", "value": ""},
              {"name": "username", "value": ""},
              {"name": "password", "value": ""},
              {"name": "category", "value": "radarr"},
              {"name": "recentPriority", "value": 0},
              {"name": "olderPriority", "value": 0},
              {"name": "initialState", "value": 0},
              {"name": "sequentialOrder", "value": false},
              {"name": "firstAndLastFirst", "value": false}
            ],
            "tags": []
          }' > /dev/null && echo "  done" || echo "  failed"
      else
        echo "Radarr → qBittorrent already configured"
      fi
    fi

    ##########################################################################
    # Bazarr → Sonarr (subtitle management for TV)
    ##########################################################################
    if [ -n "$BAZARR_KEY" ] && [ -n "$SONARR_KEY" ]; then
      # Check if Sonarr is already configured in Bazarr
      CURRENT_SONARR_KEY=$(curl -sf -H "X-API-KEY: $BAZARR_KEY" \
        "$BASE:6767/api/system/settings" | jq -r '.data.settings.sonarr.apikey // empty' 2>/dev/null || true)

      if [ -z "$CURRENT_SONARR_KEY" ]; then
        echo "Configuring Sonarr in Bazarr..."
        curl -sf -X POST \
          -H "Content-Type: application/json" \
          -H "X-API-KEY: $BAZARR_KEY" \
          "$BASE:6767/api/system/settings" \
          -d "$(jq -n --arg key "$SONARR_KEY" '{
            settings: {
              sonarr: {
                ip: "127.0.0.1",
                port: "8989",
                base_url: "/",
                ssl: "false",
                apikey: $key,
                full_update: "Daily",
                only_monitored: "false",
                series_sync: "60",
                episodes_sync: "60"
              }
            }
          }')" > /dev/null && echo "  done" || echo "  failed"
      else
        echo "Bazarr → Sonarr already configured"
      fi
    fi

    ##########################################################################
    # Bazarr → Radarr (subtitle management for movies)
    ##########################################################################
    if [ -n "$BAZARR_KEY" ] && [ -n "$RADARR_KEY" ]; then
      CURRENT_RADARR_KEY=$(curl -sf -H "X-API-KEY: $BAZARR_KEY" \
        "$BASE:6767/api/system/settings" | jq -r '.data.settings.radarr.apikey // empty' 2>/dev/null || true)

      if [ -z "$CURRENT_RADARR_KEY" ]; then
        echo "Configuring Radarr in Bazarr..."
        curl -sf -X POST \
          -H "Content-Type: application/json" \
          -H "X-API-KEY: $BAZARR_KEY" \
          "$BASE:6767/api/system/settings" \
          -d "$(jq -n --arg key "$RADARR_KEY" '{
            settings: {
              radarr: {
                ip: "127.0.0.1",
                port: "7878",
                base_url: "/",
                ssl: "false",
                apikey: $key,
                full_update: "Daily",
                only_monitored: "false",
                movies_sync: "60"
              }
            }
          }')" > /dev/null && echo "  done" || echo "  failed"
      else
        echo "Bazarr → Radarr already configured"
      fi
    fi

    echo "Interconnect setup complete."
  '';
in
{
  config = lib.mkIf (config.networking.hostName == "FredOS-Mediaserver") {

    systemd.services.arr-interconnect = {
      description = "Auto-configure connections between *arr services";
      after = [
        "sonarr.service"
        "radarr.service"
        "prowlarr.service"
        "bazarr.service"
        "qbittorrent-nox.service"
      ];
      wants = [
        "sonarr.service"
        "radarr.service"
        "prowlarr.service"
        "bazarr.service"
        "qbittorrent-nox.service"
      ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = interconnectScript;
        RemainAfterExit = true;
        # Retry once if services weren't ready
        Restart = "on-failure";
        RestartSec = "30s";
        StartLimitBurst = 3;
      };
    };

  };
}
