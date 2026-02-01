# services/bazarr.nix
{ config, pkgs, lib, ... }:
{
  config = lib.mkIf (config.networking.hostName == "FredOS-Mediaserver") {
    
    # Bazarr
    services.bazarr = {
      enable = true;
      openFirewall = true;  # Opens port 7878
      dataDir = "/var/lib/bazarr";
      user = "bazarr";
      group = "media";
    };
    
    users.users.bazarr = {
      isSystemUser = true;
      group = "media";
      extraGroups = [ "media" ];
    };
  };
}
