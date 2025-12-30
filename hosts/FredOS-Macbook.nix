{ config, pkgs, lib, ... }:

{
  config = lib.mkMerge [
    {
      nixpkgs.config.allowInsecurePredicate = pkg: 
        (lib.hasPrefix "broadcom-sta" (lib.getName pkg));
    }

    (lib.mkIf (config.networking.hostName == "FredOS-Macbook") {
      # ... all your other settings (tlp, boot, firmware) ...
      environment.systemPackages = with pkgs; [ tlp ];
      services.tlp.enable = true;
      services.power-profiles-daemon.enable = false;
      hardware.facetimehd.enable = true;
      
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
