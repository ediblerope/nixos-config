{ config, pkgs, lib, ... }:

# The outer curly braces define the attribute set returned by the module.
# Since we are using lib.mkIf, we'll use lib.mkMerge to allow the attribute set
# to be merged with any other configuration (if you had other files).
# The simplest approach is often to wrap the *entire* definition in lib.mkIf.

(lib.mkIf (config.networking.hostName == "FredOS-Gaming") { 

    # 1. Define the 32-bit package set (lib32)
    nixpkgs.config.packageOverrides = pkgs: {
      pkgs = pkgs // {
        lib32 = pkgs.pkgsi686Linux.pkgs;
      };
    };
    
    # 2. Use the packages
    environment.systemPackages = with pkgs; [
      lutris
      adwaita-icon-theme
      nix-index
      libdecor
      pkgs.lib32.libdecor # <--- CORRECT: Access via pkgs.lib32
    ];

    # 3. Graphics configuration
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    # 4. Steam configuration
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      package = pkgs.steam.override {
        extraPkgs = pkgs: with pkgs; [
          kdePackages.breeze
        ];
      };
    };

    # 5. Environment Variables
    environment.sessionVariables = {
      LIBDECOR_PLUGIN_DIR = "${pkgs.libdecor}/lib/libdecor/plugins-1";
      GTK_PATH = "${pkgs.gtk3}/lib/gtk-3.0:${pkgs.gtk4}/lib/gtk-4.0";
    };

    # 6. Auto-Upgrade configuration
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
# This closing brace and parenthesis ends the attribute set and the lib.mkIf function call
})
