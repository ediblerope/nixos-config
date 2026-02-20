# services/server-permissions.nix
{ config, pkgs, lib, ... }:
{
  config = lib.mkIf (config.networking.hostName == "FredOS-Mediaserver") {
    systemd.tmpfiles.rules = [
      # qbittorrent app data
      "d /var/lib/qbittorrent 0755 qbittorrent media -"
      "d /var/lib/qbittorrent/.config 0755 qbittorrent media -"
      "d /var/lib/qbittorrent/.config/qBittorrent 0755 qbittorrent media -"
      "d /var/lib/qbittorrent/.local 0755 qbittorrent media -"
      "d /var/lib/qbittorrent/.local/share 0755 qbittorrent media -"
      "d /var/lib/qbittorrent/.local/share/qBittorrent 0755 qbittorrent media -"

      # Storage - qbittorrent downloads here
      "d /mnt/storage/torrents/downloads 2775 qbittorrent media -"
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
