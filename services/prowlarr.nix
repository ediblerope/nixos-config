#prowlarr.nix
{ config, pkgs, lib, ... }:
{
  config = lib.mkIf (config.networking.hostName == "FredOS-Mediaserver") {
    
    # Sonarr
    services.prowlarr = {
      enable = true;
      openFirewall = true;
      dataDir = "/var/lib/prowlarr";
      user = "prowlarr";
      group = "media";
    };

    # Media group is already created in qbittorrent-nox.nix
    # Just make sure sonarr is in it
    users.users.prowlarr = {
      isSystemUser = true;
      group = "media";
      extraGroups = [ "media" ];
    };
    
    # Also add jellyfin to media group for reading
    users.users.jellyfin.extraGroups = [ "media" ];
  };
}
