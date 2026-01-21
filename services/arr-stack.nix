{ config, pkgs, lib, ... }:
{
	config = lib.mkIf (config.networking.hostName == "FredOS-Mediaserver") {
		environment.systemPackages.pkgs = [
		    qbittorrent-nox
		];
	};
}
