# hosts/FredOS-Macbook.nix
{ config, pkgs, lib, ... }:
{
  config = lib.mkIf (config.networking.hostName == "FredOS-Macbook") {
    environment.systemPackages = with pkgs; [
      # Package names here
      
    ];

    # Enable tlp service
    services.tlp.enable = true;
    
    # Bootloader
    boot = {
      loader = {
        systemd-boot.enable = true;
        efi.canTouchEfiVariables = true;
      };
      
      # Enable Broadcom WL for Macbook
      extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];
      
      blacklistedKernelModules = [
        "b43"
        "bcma"
        "ssb"
      ];
    };
    
    hardware.enableRedistributableFirmware = true;
    
    # Put nixpkgs config INSIDE the mkIf
    nixpkgs.config.permittedInsecurePackages = [
      pkgs.lib.getName config.boot.kernelPackages.broadcom_sta
    ];
  };
}
