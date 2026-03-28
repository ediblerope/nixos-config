{ config, pkgs, lib, inputs, ... }:

{
  config = lib.mkMerge [
    {
      nixpkgs.config.allowInsecurePredicate = pkg: 
        (lib.hasPrefix "broadcom-sta" (lib.getName pkg));
    }

    (lib.mkIf (config.networking.hostName == "FredOS-Macbook") {
      # ... all your other settings (tlp, boot, firmware) ...

      environment.systemPackages = with pkgs; [
        tlp
        vesktop
        adwaita-icon-theme
        mission-center
        vlc
        geary
        proton-vpn
        onlyoffice-desktopeditors
      ];


      services.tlp.enable = false;
      services.power-profiles-daemon.enable = true;

      hardware.facetimehd.enable = true;
      
      boot = {
        loader = {
          systemd-boot.enable = true;
          efi.canTouchEfiVariables = true;
        };
        extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];
        blacklistedKernelModules = [ "b43" "bcma" "ssb" ];
        kernelParams = [ "acpi_osi=" ];
      };
      hardware.enableRedistributableFirmware = true;
      boot.loader.systemd-boot.configurationLimit = 5;
      boot.initrd.systemd.enable = true;

      services.xserver.deviceSection = lib.mkDefault ''
          Option "TearFree" "true"
        '';

      #Enable Bluetooth
      hardware.bluetooth = {
        enable = true;
        powerOnBoot = true;
        settings = {
          General = {
            Enable = "Source,Sink,Media,Socket";
            Experimental = true;
          };
        };
      };
    })
  ];
}
