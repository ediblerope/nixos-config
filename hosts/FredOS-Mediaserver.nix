{ config, pkgs, lib, ... }:
{
  config = lib.mkIf (config.networking.hostName == "FredOS-Mediaserver") {
    
    # --- File Systems (Uncomment and add UUIDs as needed) ---
    # fileSystems."/mnt/disk1" = {
    #   device = "/dev/disk/by-uuid/90ae3493-38c1-4473-b409-e9d99c3b315e";
    #   fsType = "ext4";
    #   options = [ "defaults" ];
    # };

    # fileSystems."/mnt/disk4" = {
    #   device = "/dev/disk/by-uuid/PASTE_NEW_SSD_UUID_HERE";
    #   fsType = "ext4";
    #   options = [ "defaults" ];
    # };

    # fileSystems."/mnt/storage" = {
    #   device = "/mnt/disk1:/mnt/disk2:/mnt/disk3:/mnt/disk4";
    #   fsType = "fuse.mergerfs";
    #   options = [
    #     "defaults"
    #     "allow_other"
    #     "use_ino"
    #     "cache.files=partial"
    #     "dropcacheonclose=true"
    #     "category.create=mfs"
    #   ];
    # };

    # --- System Packages ---
    environment.systemPackages = with pkgs; [
      mergerfs
      wget
      btop
      util-linux
    ];

    # --- Services ---
    services.jellyfin = {
      enable = true;
      openFirewall = true;
    };

    services.openssh = {
      enable = true;
      settings.PermitRootLogin = "no";
    };

    # --- Networking ---
    networking.useDHCP = lib.mkDefault true;
    networking.firewall.allowedTCPPorts = [ 80 443 81 22 ];

    # --- Docker & Nginx Proxy Manager ---
    virtualisation.docker.enable = true;

    systemd.services.nginx-proxy-manager = {
      description = "Nginx Proxy Manager";
      after = [ "docker.service" ];
      requires = [ "docker.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        # The '-' tells systemd to ignore errors if the container doesn't exist yet
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

    # --- Bootloader ---
    boot.loader.grub = {
      enable = true;
      # We recommend using /dev/disk/by-id/ names here eventually!
      devices = [ "/dev/sda" "/dev/sdb" "/dev/sdc" "/dev/sdd" ];
      useOSProber = true;
    };

  };
}
