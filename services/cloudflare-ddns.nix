#cloudflare-ddns.nix
{ config, pkgs, lib, ... }:
{
	config = lib.mkIf (config.networking.hostName == "FredOS-Mediaserver") {
      services.cloudflare-dyndns = {
        enable = true;
        apiTokenFile = "/var/secrets/cloudflare-token";
        domains = [ "nordhammer.it" ];
      };
	};
}
