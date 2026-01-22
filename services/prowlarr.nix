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
    };
  };
}
