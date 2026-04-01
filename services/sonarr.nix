# sonarr.nix
{ config, pkgs, lib, ... }:
{
  config = lib.mkIf (config.networking.hostName == "FredOS-Mediaserver") {
    
    # Sonarr
    services.sonarr = {
      enable = true;
      openFirewall = true;
      dataDir = "/var/lib/sonarr";
      user = "sonarr";
      group = "media";
    };
    
    # Media group is already created in qbittorrent-nox.nix
    # Just make sure sonarr is in it
    users.users.sonarr = {
      isSystemUser = true;
      group = "media";
      extraGroups = [ "media" ];
    };

    systemd.tmpfiles.rules = [
      # Shows - sonarr organises, bazarr writes subtitles
      "d /mnt/storage/torrents/shows 2775 sonarr media -"
      "Z /mnt/storage/torrents/shows 2775 sonarr media -"
    ];
  };
}
