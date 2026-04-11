# services/v-rising.nix — V-Rising dedicated server via Docker
{ config, lib, ... }:
{
  config = lib.mkIf (config.networking.hostName == "FredOS-Mediaserver") {

    # Docker backend for OCI containers
    virtualisation.docker.enable = true;

    # Persistent data directories
    systemd.tmpfiles.rules = [
      "d /var/lib/v-rising                   0755 root root -"
      "d /var/lib/v-rising/server            0755 root root -"
      "d /var/lib/v-rising/persistentdata    0755 root root -"
    ];

    virtualisation.oci-containers = {
      backend = "docker";
      containers.v-rising = {
        image = "trueosiris/vrising:latest";

        volumes = [
          "/var/lib/v-rising/server:/mnt/vrising/server"
          "/var/lib/v-rising/persistentdata:/mnt/vrising/persistentdata"
        ];

        ports = [
          "9876:9876/udp"
          "9877:9877/udp"
        ];

        environment = {
          TZ          = "Europe/Stockholm";
          SERVERNAME  = "FredOS V-Rising";
          WORLDNAME   = "world1";
          # Set SERVERPASSWORD via a secrets file or leave empty for public server
          # SERVERPASSWORD = "";
        };
      };
    };

    # Open firewall for V-Rising game traffic
    networking.firewall.allowedUDPPorts = [ 9876 9877 ];
  };
}
