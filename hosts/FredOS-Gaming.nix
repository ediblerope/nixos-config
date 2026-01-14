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
      jan
    ];
    services.lact.enable = true;
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };
    services.xserver.videoDrivers = ["amdgpu"];
    boot.initrd.kernelModules = [ "amdgpu" ];
    
    # Enable AMD GPU overdrive for overclocking/undervolting
    boot.kernelParams = [ "amdgpu.ppfeaturemask=0xffffffff" ];
    
    # Session variables to make LSFG-VK work properly.
    environment.sessionVariables = {
      VK_ADD_LAYER_PATH = "${pkgs.lsfg-vk}/share/vulkan/implicit_layer.d";
      ENABLE_VKBASALT = "1";
    };

    # Create symlink for lsfg-vk layer
    systemd.user.tmpfiles.rules = [
      "L+ %h/.local/share/vulkan/implicit_layer.d/VkLayer_LS_frame_generation.json - - - - ${pkgs.lsfg-vk}/share/vulkan/implicit_layer.d/VkLayer_LS_frame_generation.json"
      "d %h/.var/app/com.hypixel.HytaleLauncher/data/vulkan/implicit_layer.d 0755 - - -"
      "L+ %h/.var/app/com.hypixel.HytaleLauncher/data/vulkan/implicit_layer.d/VkLayer_LS_frame_generation.json - - - - ${pkgs.lsfg-vk}/share/vulkan/implicit_layer.d/VkLayer_LS_frame_generation.json"
    ];
    
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
