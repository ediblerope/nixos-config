{ config, pkgs, lib, ... }:
{
  config = lib.mkIf (config.networking.hostName == "FredOS-Mediaserver") {
    ## <----- HYTALE ----> ##
    virtualisation.oci-containers = {
      backend = "docker";
      containers."hytale" = {
        image = "indifferentbroccoli/hytale-server-docker:latest";
        ports = [ "5520:5520/udp" ];
        environment = {
          SERVER_NAME = "Nordhammer.it Hytale Server";
          MAX_PLAYERS = "50";
          ENABLE_BACKUP = "true";
          BACKUP_FREQUENCY = "30";
          PASSWORD = "DukeSmells";
        };
        volumes = [
          "/home/fred/docker/hytale-server/hytale-data:/home/hytale/server-files"
        ];
        extraOptions = [
          "--stop-timeout=30"
        ];
      };
    };
    networking.firewall.allowedUDPPorts = [ 5520 ];
  };
}
