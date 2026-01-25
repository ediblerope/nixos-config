# services/radarr.nix
{ config, pkgs, lib, ... }:
{
  config = lib.mkIf (config.networking.hostName == "FredOS-Mediaserver") {
    
    # Radarr
    services.radarr = {
      enable = true;
      openFirewall = true;  # Opens port 7878
      dataDir = "/var/lib/radarr";
      user = "radarr";
      group = "media";
    };
    
    # Media group is already created in qbittorrent-nox.nix
    # Just make sure radarr is in it
    users.users.radarr = {
      isSystemUser = true;
      group = "media";
      extraGroups = [ "media" ];
    };
    
    # Set up directory structure with proper permissions
    systemd.tmpfiles.rules = [
      # Media folders - radarr writes here
      "d /mnt/storage/torrents/movies 0775 radarr media -"
      "Z /mnt/storage/torrents/movies 0775 radarr media -"
    ];
  };
}
