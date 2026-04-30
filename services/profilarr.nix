# services/profilarr.nix — Dictionarry's Profilarr quality-profile manager.
#
# Replaces the old recyclarr/TRaSH-Guides flow. Profilarr runs as a stateful
# web service with its own UI; *arr API keys, profile selections, custom
# formats, and sync schedule all live inside its own DB. Nix only owns the
# container, the storage dir, and the nginx vhost — everything else is
# configured at https://profilarr.nordhammer.it after first boot.
{ config, lib, ... }:
{
  config = lib.mkIf (config.networking.hostName == "FredOS-Mediaserver") {

    systemd.tmpfiles.rules = [
      "d /var/lib/profilarr 0755 root root -"
    ];

    virtualisation.oci-containers.containers.profilarr = {
      # Canonical image lives on Docker Hub (santiagosayshey is the maintainer);
      # the Dictionarry-Hub GHCR path that some docs mention isn't publicly pullable.
      image = "santiagosayshey/profilarr:latest";
      volumes = [
        "/var/lib/profilarr:/config"
      ];
      # Localhost-only; nginx fronts it at profilarr.nordhammer.it behind Authelia
      ports = [ "127.0.0.1:6868:6868" ];
      environment = {
        TZ = "Europe/London";
      };
    };
  };
}
