#jellyfin.nix
{ config, pkgs, lib, ... }:
{
	config = lib.mkIf (config.networking.hostName == "FredOS-Mediaserver") {
      # Jellyfin
    	services.jellyfin = {
      		enable = true;
			openFirewall = true;
    	};
		  
    	users.users.jellyfin.extraGroups = [ "media" ];
	};
}
