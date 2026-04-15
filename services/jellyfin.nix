#jellyfin.nix
{ config, pkgs, lib, ... }:
{
	config = lib.mkIf (config.networking.hostName == "FredOS-Mediaserver") {
      # Jellyfin
    	services.jellyfin = {
      		enable = true;
			openFirewall = true;
    	};

    	# Ensure Jellyfin can write thumbnails/artwork to media directories
    	systemd.services.jellyfin.serviceConfig.UMask = "0002";

    	users.users.jellyfin.extraGroups = [ "media" "video" "render" ];
	};
}
