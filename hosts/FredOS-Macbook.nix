{ config, pkgs, lib, ... }:

{
  # Use mkMerge to allow the insecure package rule to sit alongside the mkIf block
  config = lib.mkMerge [
    # 1. This part always applies if this file is imported
    {
      nixpkgs.config.permittedInsecurePackages = [
        (pkgs.lib.getName config.boot.kernelPackages.broadcom_sta)
      ];
    }

    # 2. This part only applies if the hostname matches
    (lib.mkIf (config.networking.hostName == "FredOS-Macbook") {
      environment.systemPackages = with pkgs; [
        tlp
      ];

      services.tlp.enable = true;
      services.power-profiles-daemon.enable = false;

      boot = {
        loader = {
          systemd-boot.enable = true;
          efi.canTouchEfiVariables = true;
        };
        
        extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];
        
        blacklistedKernelModules = [ "b43" "bcma" "ssb" ];
      };
      
      hardware.enableRedistributableFirmware = true;
    })
  ];
}
