# services/server-permissions.nix
{ config, pkgs, lib, ... }:
{
  config = lib.mkIf (config.networking.hostName == "FredOS-Mediaserver") {
    systemd.tmpfiles.rules = [
      # Audiobooks - manually managed, no dedicated service yet
      "d /mnt/storage/torrents/audiobooks 2775 fred media -"
      "Z /mnt/storage/torrents/audiobooks 2775 fred media -"
    ];
  };
}
