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
      };
      hardware.enableRedistributableFirmware = true;

# Enable Bluetooth
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

  # PipeWire with Bluetooth support
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    
    # Add Bluetooth codec config
    wireplumber.configPackages = [
      (pkgs.writeTextDir "share/wireplumber/bluetooth.lua.d/51-bluez-config.lua" ''
        bluez_monitor.properties = {
          ["bluez5.enable-sbc-xq"] = true,
          ["bluez5.enable-msbc"] = true,
          ["bluez5.enable-hw-volume"] = true,
          ["bluez5.headset-roles"] = "[ hsp_hs hsp_ag hfp_hf hfp_ag ]"
        }
      '')
    ];
  };

    })
  ];
}
