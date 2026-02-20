{ config, pkgs, lib, ... }:
{
	config = lib.mkIf (config.networking.hostName == "FredOS-Mediaserver") {
		environment.systemPackages = with pkgs; [
		    qbittorrent-nox
		];
		
		# Create qbittorrent user with media group
		users.users.qbittorrent = {
			isSystemUser = true;
			group = "media";
			extraGroups = [ "media" ];
			home = "/var/lib/qbittorrent";
			createHome = true;
		};
		
		# Create media group (shared with sonarr/radarr)
		users.groups.media = {
			gid = 3000;
		};
		
		systemd.services.qbittorrent-nox = {
			description = "qBittorrent-nox service";
			after = [ "network.target" ];
			wantedBy = [ "multi-user.target" ];
			serviceConfig = {
				Type = "simple";
				User = "qbittorrent";
				Group = "media";
				ExecStart = "${pkgs.qbittorrent-nox}/bin/qbittorrent-nox --confirm-legal-notice";
				Restart = "on-failure";
				
				# Security hardening - FIXED
				NoNewPrivileges = true;
				PrivateTmp = true;
				ProtectSystem = "strict";
				ProtectHome = false;  # Changed to false so it can write to /var/lib/qbittorrent
				ReadWritePaths = [ 
					"/var/lib/qbittorrent"
					"/mnt/storage/torrents"
				];
				# Set proper working directory
				WorkingDirectory = "/var/lib/qbittorrent";
			};
		};
		
		users.users.fred.extraGroups = [ "media" ];
	};
}
