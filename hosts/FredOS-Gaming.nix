# hosts/FredOS-Gaming.nix
{ config, pkgs, lib, ... }:
{
  config = lib.mkIf (config.networking.hostName == "FredOS-Gaming") {
    environment.systemPackages = with pkgs; [
      lutris
      heroic
      mangohud
      vesktop
      lsfg-vk
      lsfg-vk-ui
      faugus-launcher
      adwaita-icon-theme
      mission-center
      geary
    ];
    services.lact.enable = true;
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };
    services.xserver.videoDrivers = ["amdgpu"];
    boot.initrd.kernelModules = [ "amdgpu" ];
    
    # Enable AMD GPU overdrive for overclocking/undervolting
    boot.kernelParams = [ "amdgpu.ppfeaturemask=0xffffffff" "acpi_osi=\"!Windows 2015\"" ];

    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      package = pkgs.steam.override {
        extraPkgs = pkgs: with pkgs; [
          adwaita-icon-theme
        ];
      };
    };
    
    # Bootloader
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
    
    system.autoUpgrade = {
      enable = true;
      dates = "daily";
      persistent = true;
      allowReboot = false;
      channel = "https://nixos.org/channels/nixos-unstable";
      flags = [
        "--upgrade"
        "--option" "tarball-ttl" "0"
      ];
    };
  };
}
