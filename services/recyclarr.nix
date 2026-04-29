# services/recyclarr.nix — TRaSH-Guide quality profiles for Sonarr & Radarr.
#
# Pulls the latest custom formats + quality profiles from TRaSH and pushes
# them into each *arr's API. API keys are extracted at runtime from each
# *arr's config.xml (same pattern as arr-interconnect.nix) so there's no
# secret to manage. Runs weekly via systemd timer; idempotent.
#
# Profiles installed:
#   Sonarr:  WEB-1080p (default)         |  WEB-2160p (per-show opt-in, WEB only)
#   Radarr:  HD Bluray + WEB (default)   |  UHD Bluray + WEB (per-movie opt-in)
#
# AV1 is banned across all 4 profiles (GPU lacks hardware decode).
#
# Manual sync:  sudo systemctl start recyclarr-sync
{ config, lib, pkgs, ... }:
let
  recyclarrConfig = pkgs.writeText "recyclarr.yml" ''
    sonarr:
      sonarr-main:
        base_url: http://127.0.0.1:8989
        api_key: !env_var SONARR_API_KEY

        delete_old_custom_formats: true
        replace_existing_custom_formats: true

        quality_definition:
          type: series

        include:
          - template: sonarr-quality-definition-series
          - template: sonarr-v4-quality-profile-web-1080p
          - template: sonarr-v4-custom-formats-web-1080p
          - template: sonarr-v4-quality-profile-web-2160p
          - template: sonarr-v4-custom-formats-web-2160p

        custom_formats:
          # AV1 ban — GPU has no hardware decode for AV1.
          - trash_ids:
              - 15a05bc7c1a36e2b57fd628f8977e2fc
            assign_scores_to:
              - name: WEB-1080p
                score: -10000
              - name: WEB-2160p
                score: -10000

          # x265 (HD) preference — TRaSH defaults this to -10000 because
          # most x265-1080p is lazy re-encodes. We override to +500 to
          # actively prefer HEVC for disk space. Bad encodes are still
          # filtered by Scene/No-RlsGroup/Retags/Obfuscated (each -10000).
          - trash_ids:
              - 47435ece6b99a0b477caf360e79ba0bb
            assign_scores_to:
              - name: WEB-1080p
                score: 500

    radarr:
      radarr-main:
        base_url: http://127.0.0.1:7878
        api_key: !env_var RADARR_API_KEY

        delete_old_custom_formats: true
        replace_existing_custom_formats: true

        quality_definition:
          type: movie

        include:
          - template: radarr-quality-definition-movie
          - template: radarr-quality-profile-hd-bluray-web
          - template: radarr-custom-formats-hd-bluray-web
          - template: radarr-quality-profile-uhd-bluray-web
          - template: radarr-custom-formats-uhd-bluray-web

        custom_formats:
          # AV1 ban
          - trash_ids:
              - cae4ca30163749b891686f95532519bd
            assign_scores_to:
              - name: HD Bluray + WEB
                score: -10000
              - name: UHD Bluray + WEB
                score: -10000

          # x265 (HD) preference — same rationale as Sonarr above.
          - trash_ids:
              - dc98083864ea246d05a42df0d05f81cc
            assign_scores_to:
              - name: HD Bluray + WEB
                score: 2000
  '';

  syncScript = pkgs.writeShellScript "recyclarr-sync" ''
    set -euo pipefail
    PATH="${lib.makeBinPath [ pkgs.recyclarr pkgs.gnused pkgs.coreutils ]}:$PATH"

    extract_arr_key() {
      if [ -f "$1" ]; then
        sed -n 's/.*<ApiKey>\(.*\)<\/ApiKey>.*/\1/p' "$1"
      fi
    }

    SONARR_API_KEY=$(extract_arr_key /var/lib/sonarr/config.xml)
    RADARR_API_KEY=$(extract_arr_key /var/lib/radarr/config.xml)

    if [ -z "$SONARR_API_KEY" ] || [ -z "$RADARR_API_KEY" ]; then
      echo "Sonarr or Radarr API key not available yet — skipping sync."
      exit 0
    fi

    export SONARR_API_KEY RADARR_API_KEY

    recyclarr sync --app-data /var/lib/recyclarr --config ${recyclarrConfig}
  '';
in
{
  config = lib.mkIf (config.networking.hostName == "FredOS-Mediaserver") {

    systemd.tmpfiles.rules = [
      "d /var/lib/recyclarr 0700 root root -"
    ];

    systemd.services.recyclarr-sync = {
      description = "Sync TRaSH-Guide profiles into Sonarr & Radarr";
      after = [
        "sonarr.service"
        "radarr.service"
        "arr-interconnect.service"
        "network-online.target"
      ];
      wants = [ "network-online.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = syncScript;
      };
    };

    systemd.timers.recyclarr-sync = {
      description = "Weekly TRaSH-Guide profile sync";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "weekly";
        Persistent = true;
        RandomizedDelaySec = "30m";
      };
    };
  };
}
