{ config, pkgs, lib, ... }:
{
	config = lib.mkIf (config.networking.hostName == "FredOS-Mediaserver") {
		environment.systemPackages = with pkgs; [
		    qbittorrent-nox
		];

		systemd.services.qbittorrent-nox = {
			description = "qBittorrent-nox service";
			after = [ "network.target" ];
			wantedBy = [ "multi-user.target" ];

			serviceConfig = {
				Type = "simple";
				User = "qbittorrent";
				Group = "qbittorrent";
				ExecStart = "${pkgs.qbittorrent-nox}/bin/qbittorrent-nox";
				Restart = "on-failure";
				
				# Security hardening (optional but recommended)
				NoNewPrivileges = true;
				PrivateTmp = true;
				ProtectSystem = "strict";
				ProtectHome = "read-only";
				ReadWritePaths = [ 
					"/var/lib/qbittorrent"
					"/home/fred/storage/torrents"
				];
			};

			preStart = ''
				mkdir -p /var/lib/qbittorrent/.config/qBittorrent
				cat > /var/lib/qbittorrent/.config/qBittorrent/qBittorrent.conf << EOF
				[Preferences]
				Downloads\SavePath=/home/fred/storage/torrents/downloads
				EOF
				chown -R qbittorrent:qbittorrent /var/lib/qbittorrent/.config
			'';
		};

		# Create the user and group
		users.users.qbittorrent = {
			isSystemUser = true;
			group = "qbittorrent";
			home = "/var/lib/qbittorrent";
			createHome = true;
		};

		users.groups.qbittorrent = {};

		# Ensure the download directory exists with proper permissions
		systemd.tmpfiles.rules = [
			"d /home/fred/storage/torrents/downloads 0775 qbittorrent qbittorrent -"
		];
	};
}
