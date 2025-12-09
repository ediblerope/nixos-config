{ config, pkgs, lib, ... }:
{
  config = lib.mkIf (config.networking.hostName == "FredOS-Gaming") {
    
    environment.systemPackages = with pkgs; [
      lutris
      adwaita-icon-theme # Helps with missing cursors/icons in some Wine games
    ];

    # Enable the Gamescope Module
    programs.gamescope = {
      enable = true;
      capSysNice = false;
      # args = [ "--rt" ]; # Optional: Force realtime priority
    };
    # Enables Vulkan and OpenGL drivers
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
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
