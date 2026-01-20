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
      "d /var/lib/nginx-proxy-manager/data 0755 root root -"
      "d /var/lib/nginx-proxy-manager/letsencrypt 0755 root root -"
    ];

    # Basic system packages
    environment.systemPackages = with pkgs; [
      mergerfs
      wget
      btop
      util-linux
    ];

    # Jellyfin
    services.jellyfin = {
      enable = true;
      openFirewall = true;
    };

    # Nginx Proxy Manager
    virtualisation.docker.enable = true;
    
    systemd.services.nginx-proxy-manager = {
      description = "Nginx Proxy Manager";
      after = [ "docker.service" ];
      requires = [ "docker.service" ];
      wantedBy = [ "multi-user.target" ];
      
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStartPre = "-${pkgs.docker}/bin/docker rm -f nginx-proxy-manager";
        ExecStart = ''
          ${pkgs.docker}/bin/docker run -d \
            --name=nginx-proxy-manager \
            --restart=unless-stopped \
            -p 80:80 \
            -p 81:81 \
            -p 443:443 \
            -v /var/lib/nginx-proxy-manager/data:/data \
            -v /var/lib/nginx-proxy-manager/letsencrypt:/etc/letsencrypt \
            jc21/nginx-proxy-manager:latest
        '';
        ExecStop = "${pkgs.docker}/bin/docker stop nginx-proxy-manager";
      };
    };


  virtualisation.oci-containers = {
    backend = "docker";
    
    containers."hytale-server" = {
      image = "ghcr.io/terkea/hytale-server:latest";
      ports = [ "5520:5520/udp" ];
      environment = {
        SERVER_NAME = "Nordhammer.it Hytale Server";
        MAX_PLAYERS = "50";
        MEMORY = "4G";
        ENABLE_BACKUP = true;
        BACKUP_FREQUENCY = 30;
        PASSWORD = "DukeSmells"
      };
      volumes = [
        "/home/fred/docker/hytale-server/hytale-data:/data"
      ];
      extraOptions = [
        "--interactive=false"
        "--tty=false"
      ];
    };
  };

# Also make sure to open the firewall port
networking.firewall.allowedUDPPorts = [ 5520 ];


    # Open firewall for web traffic
    networking.firewall.allowedTCPPorts = [ 80 443 81 22 ];

    # Basic networking
    networking.useDHCP = lib.mkDefault true;

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
  };
}
