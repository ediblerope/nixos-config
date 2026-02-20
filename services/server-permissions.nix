# services/server-permissions.nix
{ config, pkgs, lib, ... }:
{
  config = lib.mkIf (config.networking.hostName == "FredOS-Mediaserver") {
    systemd.tmpfiles.rules = [
      # Downloads - qbittorrent writes here
      "Z /mnt/storage/torrents/downloads 2775 qbittorrent media -"

      # Shows - sonarr organises, bazarr writes subtitles
      "d /mnt/storage/torrents/shows 2775 sonarr media -"
      "Z /mnt/storage/torrents/shows 2775 sonarr media -"

      # Audiobooks
      "d /mnt/storage/torrents/audiobooks 2775 sonarr media -"
      "Z /mnt/storage/torrents/audiobooks 2775 sonarr media -"
    ];
  };
}
