{ config, pkgs, lib, ... }:

(lib.mkIf (config.networking.hostName == "FredOS-Gaming") { 

    nixpkgs.config.packageOverrides = pkgs: {
      pkgs = pkgs // {
        lib32 = pkgs.pkgsi686Linux.pkgs;
      };
    }; # <--- ADD SEMICOLON HERE
    
    environment.systemPackages = with pkgs; [
      lutris
      adwaita-icon-theme
      nix-index
      libdecor
      pkgs.lib32.libdecor
    ]; # <--- ADD SEMICOLON HERE

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    }; # <--- ADD SEMICOLON HERE
    
    # ... continue adding semicolons to the end of every top-level option ...
    
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      package = pkgs.steam.override {
        extraPkgs = pkgs: with pkgs; [
          kdePackages.breeze
        ];
      };
    }; # <--- ADD SEMICOLON HERE

    environment.sessionVariables = {
      LIBDECOR_PLUGIN_DIR = "${pkgs.libdecor}/lib/libdecor/plugins-1";
      GTK_PATH = "${pkgs.gtk3}/lib/gtk-3.0:${pkgs.gtk4}/lib/gtk-4.0";
    }; # <--- ADD SEMICOLON HERE

    system.autoUpgrade = {
      enable = true;
      dates = "daily";
      persistent = true;
      allowReboot = false;
      flags = [
        "--upgrade"
        "--option" "tarball-ttl" "0"
      ];
    }; # <--- ADD SEMICOLON HERE

})
