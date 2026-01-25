#/services/game-servers.nix
{ config, pkgs, lib, ... }:
{
	config = lib.mkIf (config.networking.hostName == "FredOS-Mediaserver") {
	## <----- HYTALE ----> ##
		virtualisation.oci-containers = {
			backend = "docker";
			containers."hytale" = {
				image = "ghcr.io/indifferentbroccoli/hytale-server-docker:latest";
				ports = [ "5520:5520/udp" ];
				environment = {
					SERVER_NAME = "Nordhammer.it Hytale Server";
					MAX_PLAYERS = "50";
					MEMORY = "4G";
					ENABLE_BACKUP = "true";
					BACKUP_FREQUENCY = "30";
					PASSWORD = "DukeSmells";
				};
				volumes = [
					"/home/fred/docker/hytale-server/hytale-data:/home/hytale/server-files"
				];
				extraOptions = [
					"--interactive=false"
					"--tty=false"
				];
			};
		};
		networking.firewall.allowedUDPPorts = [ 5520 ];
	};
}
