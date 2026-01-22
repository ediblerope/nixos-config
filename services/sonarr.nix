#sonarr.nix
{ config, pkgs, lib, ... }:
{
  config = lib.mkIf (config.networking.hostName == "FredOS-Mediaserver") {
    
    # Sonarr
    services.sonarr = {
      enable = true;
      openFirewall = true;
      dataDir = "/var/lib/sonarr";
      user = "sonarr";
      group = "media";
    };

    # Create a shared media group
    users.groups.media = {
      gid = 3000;  # Fixed GID for consistency
    };
    
    # Add users to media group
    users.users.sonarr = {
      isSystemUser = true;
      group = "media";
      extraGroups = [ "media" ];
    };
    
    # Assuming qbittorrent-nox user exists, add to media group
    users.users.qbittorrent-nox = {
      extraGroups = [ "media" ];
    };

    # Set up directory structure with proper permissions
    # The key is that both sonarr and qbittorrent write to the same filesystem
    # and both are in the media group with write permissions
    systemd.tmpfiles.rules = [
      # Downloads folder - qbittorrent writes here
      "d /mnt/storage/torrents/downloads 0775 qbittorrent-nox media -"
      "Z /mnt/storage/torrents/downloads 0775 qbittorrent-nox media -"  # Recursively fix existing
      
      # Media folders - sonarr writes here
      "d /mnt/storage/torrents/shows 0775 sonarr media -"
      "Z /mnt/storage/torrents/shows 0775 sonarr media -"
      "d /mnt/storage/torrents/movies 0775 sonarr media -"
      "Z /mnt/storage/torrents/movies 0775 sonarr media -"
      "d /mnt/storage/torrents/audiobooks 0775 sonarr media -"
      "Z /mnt/storage/torrents/audiobooks 0775 sonarr media -"
    ];

    # Also add jellyfin to media group for reading
    users.users.jellyfin.extraGroups = [ "media" ];
  };
}
