{ config, pkgs, lib, ... }:
{
  config = lib.mkIf (config.networking.hostName == "FredOS-Mediaserver") {
    ## <----- HYTALE ----> ##
    systemd.services.hytale-server = {
      description = "Hytale Dedicated Server";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      
      environment = {
        HYTALE_MEMORY = "8G";  # Adjust memory allocation here
      };
      
      serviceConfig = {
        Type = "simple";
        User = "fred";
        Group = "users";
        WorkingDirectory = "/home/fred/docker/hytale-server/Server";
        ExecStart = "/home/fred/docker/hytale-server/start-hytale.sh";
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
