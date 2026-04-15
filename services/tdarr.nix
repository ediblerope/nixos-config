# services/tdarr.nix — Tdarr transcoding manager
{ config, pkgs, lib, ... }:
{
  config = lib.mkIf (config.networking.hostName == "FredOS-Mediaserver") {

    systemd.services.tdarr-server = {
      description = "Tdarr Server";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        User = "tdarr";
        Group = "media";
        StateDirectory = "tdarr";
        ExecStart = "${pkgs.tdarr-server}/bin/tdarr-server";
        Restart = "on-failure";
        RestartSec = 10;

        # Tdarr server config via environment
        Environment = [
          "HOME=/var/lib/tdarr"
          "serverIP=0.0.0.0"
          "serverPort=8266"
          "webUIPort=8265"
          "internalNode=true"
          "inContainer=false"
          "ffmpegVersion=6"
          "nodeName=FredOS-Mediaserver"
        ];
      };
    };

    users.users.tdarr = {
      isSystemUser = true;
      group = "media";
      extraGroups = [ "media" "video" "render" ];
      home = "/var/lib/tdarr";
    };

    systemd.tmpfiles.rules = [
      "d /var/lib/tdarr 0755 tdarr media -"
      "d /var/lib/tdarr/server 0755 tdarr media -"
      "d /var/lib/tdarr/configs 0755 tdarr media -"
      "d /var/lib/tdarr/logs 0755 tdarr media -"
    ];
  };
}
