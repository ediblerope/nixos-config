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
		
		systemd.tmpfiles.rules = [
			# qbittorrent app data — Z recursively enforces ownership/perms on boot
			# (self-heals UID/GID drift from migrations etc.)
			"d /var/lib/qbittorrent 0755 qbittorrent media -"
			"Z /var/lib/qbittorrent 0755 qbittorrent media -"

			# Storage - qbittorrent downloads here
			"d /mnt/storage/torrents/downloads 2775 qbittorrent media -"
			"Z /mnt/storage/torrents/downloads 2775 qbittorrent media -"
		];

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
				UMask = "0002";

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
