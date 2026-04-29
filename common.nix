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
    ./services/authelia.nix
    ./services/homepage.nix
    ./services/arr-interconnect.nix
    ./services/recyclarr.nix
    ./services/adguard.nix
    ./services/router.nix
    ./services/crowdsec.nix
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

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    # Default max-jobs is the host's core count, which on the 56-core
    # mediaserver was launching ~56 parallel gcc builds and blowing past
    # 30 GiB RAM during gnupg/openldap. Cap parallel builds and per-build
    # cores so a local rebuild storm can't OOM the box.
    max-jobs = 4;
    cores = 8;
  };

  # Compressed in-memory swap as a safety net during local build storms.
  # Without it, OOM stalls AdGuard/Jellyfin to the point of freezing the box.
  zramSwap = {
    enable = true;
    memoryPercent = 50;
  };

  # Keep services responsive when nix-daemon is contending for CPU.
  systemd.services.nix-daemon.serviceConfig.CPUWeight = 50;

  # Use latest kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # openldap 2.6.13's test017-syncreplication-refresh is timing-flaky on
  # unstable's freshly-bumped revisions before Hydra has cached them. The
  # mediaserver runs on the stable channel where openldap is always cached,
  # so don't change its hash there — that would force a local rebuild.
  nixpkgs.overlays = lib.optionals (config.networking.hostName != "FredOS-Mediaserver") [
    (final: prev: {
      openldap = prev.openldap.overrideAttrs (_: { doCheck = false; });
    })
  ];

  # Enable network-manager
  networking.networkmanager.enable = true;

  # Fish shell
  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;

  # Shell aliases (work in both bash and fish)
  environment.shellAliases = {
    update = "bash -c 'OLD_SYSTEM=$(readlink /run/current-system) && sudo nixos-rebuild build $@ --impure --flake github:ediblerope/nixos-config && sudo nixos-rebuild switch $@ --impure --flake github:ediblerope/nixos-config && nvd diff $OLD_SYSTEM /run/current-system && (command -v record-update &>/dev/null && record-update $OLD_SYSTEM /run/current-system || true) && command -v matugen &>/dev/null && matugen image ~/.local/share/backgrounds/wallpaper.png -m dark || true' --";
    clean = "sudo nix-collect-garbage -d";
    ll = "ls -alh";
    clear = "command clear";
    reboot = "sudo systemctl reboot";
  };

  # Add packages
  environment.systemPackages = with pkgs; [
      git
      localsend
      nvd
      busybox
  ];
}
