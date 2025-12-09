{ config, pkgs, lib, ... }:
{
  config = lib.mkIf (config.networking.hostName == "FredOS-Gaming") {
    
    environment.systemPackages = with pkgs; [
      lutris
      dwaita-icon-theme # Helps with missing cursors/icons in some Wine games
    ];

    # 1. Enable the Gamescope Module
    programs.gamescope = {
      enable = true;
      capSysNice = true; # Fixes "No CAP_SYS_NICE" warning implies better performance
      # args = [ "--rt" ]; # Optional: Force realtime priority
    };

    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      package = pkgs.steam.override {
        extraPkgs = pkgs: with pkgs; [
          kdePackages.breeze
          libgdiplus # Often helps with Wine UI rendering
        ];
      };
    };

    system.autoUpgrade = {
      enable = true;
      dates = "daily";
      persistent = true;
      allowReboot = false;
      flags = [
        "--upgrade"
        "--option" "tarball-ttl" "0"
      ];
    };
  };
}
