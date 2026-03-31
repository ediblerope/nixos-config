# hosts/FredOS-Gaming.nix
{ config, pkgs, lib, inputs, ... }:
{
  config = lib.mkIf (config.networking.hostName == "FredOS-Gaming") {
    environment.systemPackages = with pkgs; [
      lutris
      #(heroic.override {
      #  extraPkgs = pkgs: with pkgs; [
      #    adwaita-icon-theme
      #  ];
      #})
      mangohud
      goofcord
      lsfg-vk
      lsfg-vk-ui
      faugus-launcher
      adwaita-icon-theme
      mission-center
      geary
      wowup-cf
      adwsteamgtk
      proton-vpn
      onlyoffice-desktopeditors
      vscodium
    ];
    
    services.lact.enable = true;
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };
    services.xserver.videoDrivers = ["amdgpu"];
    boot.initrd.kernelModules = [ "amdgpu" ];
    
    # Enable AMD GPU overdrive for overclocking/undervolting
    boot.kernelParams = [ "amdgpu.ppfeaturemask=0xffffffff" "acpi_osi=\"!Windows 2015\"" "amdgpu.freesync_video=1"];

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
    boot.loader.systemd-boot.configurationLimit = 5;
    boot.initrd.systemd.enable = true;
  };
}
