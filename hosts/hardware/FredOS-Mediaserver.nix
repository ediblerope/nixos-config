#./hosts/hardware/FredOS-Mediaserver.nix
{ config, lib, pkgs, modulesPath, ... }:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [ "ahci" "xhci_pci" "ata_generic" "ehci_pci" "usbhid" "usb_storage" "sd_mod" "rtsx_usb_sdmmc" ];
  boot.initrd.kernelModules = [ ];
  # nvidia_uvm is required for CUDA (used by NVENC/NVDEC in Jellyfin).
  # The other nvidia modules are loaded via services.xserver.videoDrivers but
  # nvidia_uvm is not pulled in automatically on a headless system.
  boot.kernelModules = [ "kvm-intel" "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/092fa47c-2ebd-4fbb-84f1-ce9cd606ed67";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/2E97-CB68";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };

  # Data disks
  fileSystems."/mnt/disk1" = {
    device = "/dev/disk/by-uuid/90ae3493-38c1-4473-b409-e9d99c3b315e";
    fsType = "ext4";
  };

  fileSystems."/mnt/disk2" = {
    device = "/dev/disk/by-uuid/58cecfd5-2fd7-4c4b-b3a1-0bf5e9d0beab";
    fsType = "ext4";
  };

  fileSystems."/mnt/disk3" = {
    device = "/dev/disk/by-uuid/317660ef-bd75-4fa4-bd20-f96a3926bf7b";
    fsType = "ext4";
  };

  # Combined MergerFS pool
  fileSystems."/mnt/storage" = {
    device = "/mnt/disk1:/mnt/disk2:/mnt/disk3";
    fsType = "fuse.mergerfs";
    options = [
      "defaults"
      "allow_other"
      "use_ino"
      "cache.files=partial"
      "dropcacheonclose=true"
      "category.create=mfs"
    ];
  };

  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # NVIDIA Quadro M2000 (Maxwell/GM206) — for Jellyfin NVENC hardware transcoding
  hardware.graphics.enable = true;
  hardware.nvidia = {
    modesetting.enable = true;
    open = false; # Maxwell architecture does not support the open kernel module
    nvidiaSettings = false; # headless server, no settings GUI needed
  };
  services.xserver.videoDrivers = [ "nvidia" ];
  networking.hostName = "FredOS-Mediaserver";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  system.stateVersion = "25.11";
}
