{ config, pkgs, lib, ... }:

{
	config = lib.mkIf (config.networking.hostName == "FredOS-Mediaserver") {

		virtualisation.oci-containers = {
		  backend = "docker";
		
		  containers."authelia" = {
		    image = "authelia/authelia:latest";
		    volumes = [
		      "/home/fred/docker/authelia/config.yml:/config/config.yml:ro"
		      "/home/fred/docker/authelia/secrets:/secrets:ro"
		    ];
		    ports = [ "9091:9091" ];
		    extraOptions = "--restart unless-stopped";
		  };
		
		  containers."go2rtc" = {
		    image = "blakeblackshear/go2rtc:latest";
		    volumes = [
		      "/home/fred/docker/go2rtc/config.yml:/config/config.yml:ro"
		    ];
		    ports = [ "1984:1984" ];
		    extraOptions = "--restart unless-stopped";
		  };
		};
	};
}
