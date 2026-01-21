{ config, pkgs, lib, ... }:
{
	config = lib.mkIf (config.networking.hostName == "FredOS-Mediaserver") {
		environment.systemPackages = with pkgs [
		    qbittorrent-nox
		];
	};
}
