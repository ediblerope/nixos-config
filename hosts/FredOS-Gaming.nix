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
      faugus-launcher
      adwaita-icon-theme
      mission-center
      geary
    ];
    services.lact.enable = true;
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = [ pkgs.lsfg-vk ];  # ADD THIS - makes it available to 64-bit apps
      extraPackages32 = [ pkgs.lsfg-vk ]; # ADD THIS - makes it available to 32-bit games
    };
    services.xserver.videoDrivers = ["amdgpu"];
    boot.initrd.kernelModules = [ "amdgpu" ];
    
    # Enable AMD GPU overdrive for overclocking/undervolting
    boot.kernelParams = [ "amdgpu.ppfeaturemask=0xffffffff" "acpi_osi=\"!Windows 2015\"" ];
    
    # Session variables - REMOVE ENABLE_VKBASALT, it's for vkBasalt not LSFG-VK
    environment.sessionVariables = {
      VK_ADD_LAYER_PATH = "${pkgs.lsfg-vk}/share/vulkan/implicit_layer.d";
      # REMOVE THIS: ENABLE_VKBASALT = "1";
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
          lsfg-vk  # ADD THIS - includes LSFG-VK in Steam runtime
        ];
      };
    };
    # ... rest of your config
  };
}
