# Common.nix
{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    # Hosts #
    ./hosts/FredOS-Gaming.nix
    ./hosts/FredOS-Macbook.nix
    ./hosts/FredOS-Mediaserver.nix
    
    # Generic settings #
    ./settings/gnome.nix
    ./settings/locale.nix
    ./settings/audio.nix
    ./settings/users.nix
    ./apps/fastfetch.nix
    ./apps/flatpaks.nix
    ./apps/zen.nix

    # Services #
    ./services/server-permissions.nix
    #./services/game-servers.nix
    ./services/qbittorrent-nox.nix
    ./services/nginx.nix
    ./services/go2rtc.nix
    ./services/sonarr.nix
    ./services/radarr.nix
    ./services/prowlarr.nix
    ./services/jellyfin.nix
    ./services/bazarr.nix
    ./services/cloudflare-ddns.nix
    ./services/omnisearch.nix
  ];

  ### Make build time quicker
  documentation.nixos.enable = false;

  # Home Manager #
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.extraSpecialArgs = { inherit inputs; };
  home-manager.users.fred = import ./home-manager/fred.nix;

#############################################################################
  # Make boot time quicker
  boot.loader.timeout = 5;
  systemd.services.NetworkManager-wait-online.enable = false;
  systemd.services.systemd-udev-settle.enable = false;
  systemd.services.firewall = {
    wantedBy = lib.mkForce [ ];
    after = [ "multi-user.target" ];
  };

  boot.initrd.verbose = false;
#############################################################################

  # Use latest kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable network-manager
  networking.networkmanager.enable = true;
  networking.nameservers = [ "1.1.1.1" "9.9.9.9" ];

  # Shell aliases
  environment.shellAliases = {
    update = "sudo nixos-rebuild switch --flake github:ediblerope/nixos-config --refresh --no-write-lock-file";
    clean = "sudo nix-collect-garbage -d";
    ll = "ls -alh";
    clear = "command clear && fastfetch --config /etc/fastfetch/config.jsonc";
    reboot = "systemctl reboot";
  };

  # Add packages
  environment.systemPackages = with pkgs; [
      git
      localsend
      onlyoffice-desktopeditors
  ];
}
