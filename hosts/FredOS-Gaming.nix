{ config, pkgs, lib, ... }:
{
  config = lib.mkIf (config.networking.hostName == "FredOS-Gaming") {

    nixpkgs.config.packageOverrides = pkgs: {
      pkgs = pkgs // {
        # This is where you pull in 32-bit packages
        # We access the i686-linux architecture set:
        lib32 = pkgs.pkgsi686Linux.pkgs;
      };
    };
    
    environment.systemPackages = with pkgs; [
      lutris
      adwaita-icon-theme # Helps with missing cursors/icons in some Wine games
      nix-index
      libdecor
      lib32.libdecor
    ];

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
        ];
      };
    };

  	# Set libdecor plugin directory
  	environment.sessionVariables = {
  		LIBDECOR_PLUGIN_DIR = "${pkgs.libdecor}/lib/libdecor/plugins-1";
      GTK_PATH = "${pkgs.gtk3}/lib/gtk-3.0:${pkgs.gtk4}/lib/gtk-4.0";
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
