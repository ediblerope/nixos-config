{ config, pkgs, lib, ... }:
{
  config = lib.mkIf (config.networking.hostName == "FredOS-Mediaserver") {
    ## <----- V-RISING ----> ##
    virtualisation.docker.enable = true;

    systemd.tmpfiles.rules = [
      "d /var/lib/v-rising                   0755 root root -"
      "d /var/lib/v-rising/server            0755 root root -"
      "d /var/lib/v-rising/persistentdata    0755 root root -"
    ];

    virtualisation.oci-containers = {
      backend = "docker";
      containers.v-rising = {
        image = "trueosiris/vrising:latest";
        entrypoint = "/bin/bash";
        cmd = [ "-c" "sed -i 's/\\r$//' /start.sh && /start.sh" ];

        volumes = [
          "/var/lib/v-rising/server:/mnt/vrising/server"
          "/var/lib/v-rising/persistentdata:/mnt/vrising/persistentdata"
        ];

        ports = [
          "9876:9876/udp"
          "9877:9877/udp"
        ];

        environment = {
          TZ         = "Europe/Stockholm";
          SERVERNAME = "FredOS V-Rising";
          WORLDNAME  = "world1";
          # SERVERPASSWORD = "";
        };
      };
    };

    ## <----- HYTALE ----> ##
    # systemd.services.hytale-server = {
    #   description = "Hytale Dedicated Server";
    #   wantedBy = [ "multi-user.target" ];
    #   after = [ "network.target" ];
    #
    #   path = with pkgs; [ bash jdk unzip gawk gnugrep coreutils screen ];
    #
    #   environment = {
    #     HYTALE_MEMORY = "8G";
    #   };
    #
    #   serviceConfig = {
    #     Type = "forking";
    #     User = "fred";
    #     Group = "users";
    #     WorkingDirectory = "/home/fred/docker/hytale-server/Server";
    #     ExecStart = "${pkgs.screen}/bin/screen -dmS hytale /home/fred/docker/hytale-server/start-hytale.sh";
    #     ExecStop = "${pkgs.screen}/bin/screen -S hytale -X stuff 'stop^M'";
    #     RemainAfterExit = "yes";
    #     Restart = "on-failure";
    #     RestartSec = "10s";
    #     TimeoutStopSec = "30s";
    #
    #     # Security hardening
    #     NoNewPrivileges = true;
    #     PrivateTmp = true;
    #   };
    # };

    networking.firewall.allowedUDPPorts = [ 9876 9877 ];
  };
}
