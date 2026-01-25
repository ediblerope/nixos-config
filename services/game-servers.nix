{ config, pkgs, lib, ... }:
{
  config = lib.mkIf (config.networking.hostName == "FredOS-Mediaserver") {
    ## <----- HYTALE ----> ##
    systemd.services.hytale-server = {
      description = "Hytale Dedicated Server";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      
      path = with pkgs; [ bash jdk unzip gawk gnugrep coreutils screen ];  # Added screen
      
      environment = {
        HYTALE_MEMORY = "8G";
      };
      
      serviceConfig = {
        Type = "forking";  # Changed from "simple"
        User = "fred";
        Group = "users";
        WorkingDirectory = "/home/fred/docker/hytale-server/Server";
        ExecStart = "${pkgs.screen}/bin/screen -dmS hytale /home/fred/docker/hytale-server/start-hytale.sh";
        ExecStop = "${pkgs.screen}/bin/screen -S hytale -X stuff 'stop^M'";
        RemainAfterExit = "yes";
        Restart = "on-failure";
        RestartSec = "10s";
        TimeoutStopSec = "30s";
        
        # Security hardening
        NoNewPrivileges = true;
        PrivateTmp = true;
      };
    };
    
    networking.firewall.allowedUDPPorts = [ 5520 ];
  };
}
