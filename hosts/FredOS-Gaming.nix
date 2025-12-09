{ config, pkgs, lib, ... }:

(lib.mkIf (config.networking.hostName == "FredOS-Gaming") { 

    nixpkgs.config.packageOverrides = pkgs: {
      pkgs = pkgs // {
        lib32 = pkgs.pkgsi686Linux.pkgs;
      };
    }; # <--- REMOVE THE SEMICOLON HERE
    
    environment.systemPackages = [
      pkgs.lutris; # Add semicolons to the array elements for robustness
      pkgs.adwaita-icon-theme;
      pkgs.nix-index;
      pkgs.libdecor;
      pkgs.lib32.libdecor;
    ]; # <--- SEMICOLON (Required for environment.systemPackages)

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    }; # <--- SEMICOLON (Required)

    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      package = pkgs.steam.override {
        extraPkgs = pkgs: with pkgs; [
          kdePackages.breeze
        ];
      };
    }; # <--- SEMICOLON (Required)

    environment.sessionVariables = {
      LIBDECOR_PLUGIN_DIR = "${pkgs.libdecor}/lib/libdecor/plugins-1";
      GTK_PATH = "${pkgs.gtk3}/lib/gtk-3.0:${pkgs.gtk4}/lib/gtk-4.0";
    }; # <--- SEMICOLON (Required)

    system.autoUpgrade = {
      enable = true;
      dates = "daily";
      persistent = true;
      allowReboot = false;
      flags = [
        "--upgrade"
        "--option" "tarball-ttl" "0"
      ];
    }; # <--- SEMICOLON (Required)
    
# Closing brace for the attribute set, closing parenthesis for lib.mkIf
})
