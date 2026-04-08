#./hosts/hardware/FredOS-Mediaserver.nix
{ config, lib, pkgs, modulesPath, ... }:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "uhci_hcd" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/6008e793-4b24-4e62-821f-7a204fef5729";
    fsType = "ext4";
  };

  # Individual Data Disks
  fileSystems."/mnt/disk1" = {
    device = "/dev/disk/by-uuid/90ae3493-38c1-4473-b409-e9d99c3b315e";
    fsType = "ext4";
  };

  fileSystems."/mnt/disk2" = {
    device = "/dev/disk/by-uuid/7145223e-f285-424a-a114-cb0b1b64e068";
    fsType = "ext4";
  };

  fileSystems."/mnt/disk3" = {
    device = "/dev/disk/by-uuid/58cecfd5-2fd7-4c4b-b3a1-0bf5e9d0beab";
    fsType = "ext4";
  };

  fileSystems."/mnt/disk4" = {
    device = "/dev/disk/by-uuid/317660ef-bd75-4fa4-bd20-f96a3926bf7b";
    fsType = "ext4";
  };

  # The Combined MergerFS Pool
  fileSystems."/mnt/storage" = {
    device = "/mnt/disk1:/mnt/disk2:/mnt/disk3:/mnt/disk4";
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

  nixpkgs.stdenv.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  networking.hostName = "FredOS-Mediaserver";

  boot.loader.grub = {
    enable = true;
    # Includes all 4 physical disks for redundancy
    devices = [ "/dev/sda" "/dev/sdb" "/dev/sdc" "/dev/sdd" "/dev/sde" ];
    useOSProber = true;
  };

  system.stateVersion = "25.11";
}
