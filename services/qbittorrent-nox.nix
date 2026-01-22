#qbittorrent-nox.nix
{ config, pkgs, lib, ... }:
{
	config = lib.mkIf (config.networking.hostName == "FredOS-Mediaserver") {
		environment.systemPackages = with pkgs; [
		    qbittorrent-nox
		];
		
		# Create qbittorrent user with media group
		users.users.qbittorrent = {
			isSystemUser = true;
			group = "media";  # Changed to media group for sharing
			extraGroups = [ "media" ];
			home = "/var/lib/qbittorrent";
			createHome = true;
		};
		
		# Create media group (shared with sonarr)
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
				Group = "media";  # Changed to media
				ExecStart = "${pkgs.qbittorrent-nox}/bin/qbittorrent-nox";
				Restart = "on-failure";
				
				# Security hardening
				NoNewPrivileges = true;
				PrivateTmp = true;
				ProtectSystem = "strict";
				ProtectHome = true;
				ReadWritePaths = [ 
					"/var/lib/qbittorrent"
					"/mnt/storage/torrents"
				];
			};
			preStart = ''
				mkdir -p /var/lib/qbittorrent/.config/qBittorrent
				cat > /var/lib/qbittorrent/.config/qBittorrent/qBittorrent.conf << EOF
				[Preferences]
				Downloads\SavePath=/mnt/storage/torrents/downloads
				EOF
				chown -R qbittorrent:media /var/lib/qbittorrent/.config
			'';
		};
		
		# Ensure the download directory exists with proper permissions
		systemd.tmpfiles.rules = [
			"d /mnt/storage/torrents/downloads 0775 qbittorrent media -"
		];
		
		users.users.fred.extraGroups = [ "media" ];  # Changed to media group
	};
}
