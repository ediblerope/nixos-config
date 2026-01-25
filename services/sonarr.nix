# sonarr.nix
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
    
    # Media group is already created in qbittorrent-nox.nix
    # Just make sure sonarr is in it
    users.users.sonarr = {
      isSystemUser = true;
      group = "media";
      extraGroups = [ "media" ];
    };
    
    # Set up directory structure with proper permissions
    systemd.tmpfiles.rules = [
      # Downloads folder - qbittorrent writes here (already in qbittorrent-nox.nix)
      "Z /mnt/storage/torrents/downloads 0775 qbittorrent media -"
      
      # Media folders - sonarr writes here
      "d /mnt/storage/torrents/shows 0775 sonarr media -"
      "Z /mnt/storage/torrents/shows 0775 sonarr media -"
      "d /mnt/storage/torrents/audiobooks 0775 sonarr media -"
      "Z /mnt/storage/torrents/audiobooks 0775 sonarr media -"
    ];
  };
}
