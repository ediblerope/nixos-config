#jellyfin.nix
{ config, pkgs, lib, ... }:
{
	config = lib.mkIf (config.networking.hostName == "FredOS-Mediaserver") {
      services.cloudflare-dyndns = {
        enable = true;
        apiTokenFile = "/var/secrets/cloudflare-token";
        domains = [ "nordhammer.it" ]; # or subdomain.yourdomain.com
        # Optional: specify which network interface to get IP from
        # ipv4 = true;  # default
        # ipv6 = false; # default
      };
	};
}
