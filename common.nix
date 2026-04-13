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
    ./settings/shell.nix
    ./apps/zen.nix

    # Services #
    ./services/server-permissions.nix
    ./services/game-servers.nix
    ./services/qbittorrent-nox.nix
    ./services/nginx.nix
    ./services/go2rtc.nix
    ./services/sonarr.nix
    ./services/radarr.nix
    ./services/prowlarr.nix
    ./services/jellyfin.nix
    ./services/bazarr.nix
    ./services/cloudflare-ddns.nix
    ./services/fail2ban.nix
    ./services/authelia.nix
    ./services/homepage.nix
    ./services/arr-interconnect.nix
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
  boot.loader.timeout = lib.mkDefault 5;
  systemd.services.NetworkManager-wait-online.enable = false;
  systemd.services.systemd-udev-settle.enable = false;
  systemd.services.firewall = {
    wantedBy = lib.mkForce [ ];
    after = [ "multi-user.target" ];
  };

  boot.initrd.verbose = false;
#############################################################################

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Use latest kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable network-manager
  networking.networkmanager.enable = true;
  networking.nameservers = [ "1.1.1.1" "9.9.9.9" ];

  # Fish shell
  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;

  # Shell aliases (work in both bash and fish)
  environment.shellAliases = {
    update = "bash -c 'OLD_SYSTEM=$(readlink /run/current-system) && sudo nixos-rebuild build $@ --flake github:ediblerope/nixos-config && sudo nixos-rebuild switch $@ --flake github:ediblerope/nixos-config && nvd diff $OLD_SYSTEM /run/current-system' --";
    clean = "sudo nix-collect-garbage -d";
    ll = "ls -alh";
    clear = "command clear";
    reboot = "systemctl reboot";
  };

  # Add packages
  environment.systemPackages = with pkgs; [
      git
      localsend
      nvd
  ];
}
