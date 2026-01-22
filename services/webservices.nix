{ config, pkgs, lib, ... }:
{
	config = lib.mkIf (config.networking.hostName == "FredOS-Mediaserver") {

		# Nginx Proxy Manager
		virtualisation.oci-containers = {
	      backend = "docker";
	      
	      containers."nginx-proxy-manager" = {
	        image = "jc21/nginx-proxy-manager:latest";
	        ports = [ 
	          "80:80"
	          "81:81"
	          "443:443"
	        ];
	        volumes = [
	          "/home/fred/docker/nginx-proxy-manager/data:/data"
	          "/home/fred/docker/nginx-proxy-manager/letsencrypt:/etc/letsencrypt"
	        ];
	        # Remove the extraOptions with --restart, it conflicts with --rm
	      };
	    };
	    
	    # Create directories
	    systemd.tmpfiles.rules = [
	      "d /home/fred/docker/nginx-proxy-manager/data 0755 root root -"
	      "d /home/fred/docker/nginx-proxy-manager/letsencrypt 0755 root root -"
	    ];
	    
	    # Open firewall
	    networking.firewall.allowedTCPPorts = [ 80 81 443 ];

		# Jellyfin
    	services.jellyfin = {
      		enable = true;
			openFirewall = true;
    	};
		# Also add jellyfin to media group for reading
    	users.users.jellyfin.extraGroups = [ "media" ];
	};
}
