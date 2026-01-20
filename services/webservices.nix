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
          "/var/lib/nginx-proxy-manager/data:/data"
          "/var/lib/nginx-proxy-manager/letsencrypt:/etc/letsencrypt"
        ];
        extraOptions = [
          "--restart=unless-stopped"
        ];
      };
    };
    
    # Create directories
    systemd.tmpfiles.rules = [
      "d /var/lib/nginx-proxy-manager/data 0755 root root -"
      "d /var/lib/nginx-proxy-manager/letsencrypt 0755 root root -"
    ];
    
    # Open firewall
    networking.firewall.allowedTCPPorts = [ 80 81 443 ];

	# Jellyfin
    services.jellyfin = {
      enable = true;
      openFirewall = true;
    };

}
