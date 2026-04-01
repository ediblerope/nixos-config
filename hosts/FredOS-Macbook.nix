{ config, pkgs, lib, inputs, ... }:

{
  config = lib.mkIf (config.networking.hostName == "FredOS-Macbook") {
    environment.systemPackages = with pkgs; [
      tlp
      vesktop
      adwaita-icon-theme
      mission-center
      vlc
      geary
      proton-vpn
      onlyoffice-desktopeditors
    ];

    services.tlp.enable = false;
    services.power-profiles-daemon.enable = true;

    boot.loader.systemd-boot.configurationLimit = 5;
    boot.initrd.systemd.enable = true;
  };
}
