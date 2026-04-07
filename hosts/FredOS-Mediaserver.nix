{ config, pkgs, lib, ... }:
{
  config = lib.mkIf (config.networking.hostName == "FredOS-Mediaserver") {
    # Create symlink from home to storage
    systemd.tmpfiles.rules = [
      "L+ /home/fred/storage - - - - /mnt/storage"
    ];

    # Basic system packages
    environment.systemPackages = with pkgs; [
      mergerfs
      wget
      btop
      util-linux
      javaPackages.compiler.temurin-bin.jre-25
      unzip
      screen
      yt-dlp
    ];

    # Basic networking
    networking.useDHCP = lib.mkDefault true;

    # Open firewall for SSH
    networking.firewall.allowedTCPPorts = [ 22 ];
    services.openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
      };
    };
  };
}
