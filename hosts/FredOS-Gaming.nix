{ config, pkgs, lib, ... }:
(lib.mkIf (config.networking.hostName == "FredOS-Gaming") { 
    
    # Remove this entire packageOverrides section - it's not working
    
    environment.systemPackages = [
      pkgs.lutris
      pkgs.adwaita-icon-theme
      pkgs.nix-index
      pkgs.libdecor
      pkgs.pkgsi686Linux.libdecor  # This is the correct way
    ];
    
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    }; # <--- Semicolon required here

    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      package = pkgs.steam.override {
        extraPkgs = pkgs: with pkgs; [
          kdePackages.breeze
        ];
      };
    }; # <--- Semicolon required here

    environment.sessionVariables = {
      LIBDECOR_PLUGIN_DIR = "${pkgs.libdecor}/lib/libdecor/plugins-1";
      GTK_PATH = "${pkgs.gtk3}/lib/gtk-3.0:${pkgs.gtk4}/lib/gtk-4.0";
    }; # <--- Semicolon required here

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
    
})
