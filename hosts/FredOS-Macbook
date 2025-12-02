# hosts/FredOS-Macbook.nix
{ config, pkgs, lib, ... }:

{
  config = lib.mkIf (config.networking.hostName == "FredOS-Macbook") {
    environment.systemPackages = with pkgs; [
      # Package names here
    ];
    
    # Bootloader
    boot = {
      loader = {
        systemd-boot.enable = true;
        efi.canTouchEfiVariables = true;
      };
      
      # Enable Broadcom WL for Macbook
      extraModulePackages = [ pkgs.linuxPackages.broadcom_sta ];  # Use pkgs, not config
      
      blacklistedKernelModules = [
        "b43"
        "bcma"
        "ssb"
      ];
    };
    
    hardware.enableRedistributableFirmware = true;
    
    nixpkgs.config.permittedInsecurePackages = [
      "broadcom-sta-6.30.223.271-59-6.17.9"
    ];
  };
}
