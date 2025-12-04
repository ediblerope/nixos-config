# hosts/FredOS-Macbook.nix
{ config, pkgs, lib, ... }:
{
  # Move this OUTSIDE the mkIf
  nixpkgs.config.permittedInsecurePackages = [
    "broadcom-sta-6.30.223.271-59-6.18"
  ];

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
      # Use config.boot.kernelPackages to match the kernel version from common.nix
      extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];
      
      blacklistedKernelModules = [
        "b43"
        "bcma"
        "ssb"
      ];
    };
    
    hardware.enableRedistributableFirmware = true;
  };
}
