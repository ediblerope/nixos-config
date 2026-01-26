{ config, pkgs, lib, ... }:
{
  config = lib.mkIf (config.networking.hostName == "FredOS-Mediaserver") {
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

    # The Combined MergerFS Pool
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

    # Create symlink from home to storage
    systemd.tmpfiles.rules = [
      "L+ /home/fred/storage - - - - /mnt/storage"
    ];

    # Basic system packages
    environment.systemPackages = with pkgs; [
      mergerfs
      wget
      btop
      util-linux
      javaPackages.compiler.temurin-bin.jre-25
      unzip
      screen
      yt-dlp
    ];

    # Enable Docker
    virtualisation.docker.enable = true;
    
    # Basic networking
    networking.useDHCP = lib.mkDefault true;

    # Open firewall for SSH
    networking.firewall.allowedTCPPorts = [ 22 ];
    services.openssh = {
      enable = true;
      settings.PermitRootLogin = "no";
    };

    # Boot loader
    boot.loader.grub = {
      enable = true;
      # Includes all 4 physical disks for redundancy
      devices = [ "/dev/sda" "/dev/sdb" "/dev/sdc" "/dev/sdd" ];
      useOSProber = true;
    };

    # Auto-update + upgrade
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
