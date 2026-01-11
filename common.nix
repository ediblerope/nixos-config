# Common.nix
{ config, pkgs, lib, ... }:

{
  imports = [
    ./settings/gnome.nix
    ./settings/locale.nix
    ./settings/audio.nix
    ./settings/users.nix
    ./settings/gdm-monitor.nix
    ./apps/fastfetch.nix
    ./apps/flatpaks.nix
  ];
#############################################################################
  # Make boot time quicker
  boot.loader.timeout = 0;
  systemd.services.NetworkManager-wait-online.enable = false;
  systemd.services.systemd-udev-settle.enable = false;
  systemd.services.firewall = {
    wantedBy = lib.mkForce [ ];
    after = [ "multi-user.target" ];
  };
  systemd.services.home-manager-fred = {
    wantedBy = lib.mkForce [ ];
    after = [ "multi-user.target" ];
  };
  boot.initrd.systemd.enable = true;
  boot.initrd.verbose = false;
#############################################################################

  # Use latest kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable network-manager
  networking.networkmanager.enable = true;

  # Shell aliases
  environment.shellAliases = {
    update = ''
      CHANNEL=$(sudo nix-channel --list | grep "^nixos " | awk '{print $2}')
      if [[ "$CHANNEL" != *"nixos-unstable"* ]]; then
        echo "Switching to nixos-unstable channel..."
        sudo nix-channel --add https://nixos.org/channels/nixos-unstable nixos
        sudo nix-channel --update
      fi
      
      # Add nix-flatpak channel if not present
      if ! sudo nix-channel --list | grep -q "nix-flatpak"; then
        echo "Adding nix-flatpak channel..."
        sudo nix-channel --add https://github.com/gmodena/nix-flatpak/archive/main.tar.gz nix-flatpak
      fi
      
      sudo nix-channel --update
      echo "Cleaning Flatpak state cache..."
      sudo rm -f /nix/var/nix/gcroots/flatpak-state.json
      sudo nixos-rebuild switch --upgrade --option tarball-ttl 0
      
      # Manually reapply wallpaper settings
      dconf write /org/gnome/desktop/background/picture-uri "'file://''${HOME}/.local/share/backgrounds/wallpaper.png'"
      dconf write /org/gnome/desktop/background/picture-uri-dark "'file://''${HOME}/.local/share/backgrounds/wallpaper.png'"
      dconf write /org/gnome/desktop/background/picture-options "'zoom'"
    '';
    clean = "sudo nix-collect-garbage -d";
    ll = "ls -alh";
    clear = "command clear && fastfetch --config /etc/fastfetch/config.jsonc";
  };

  # Add packages
  environment.systemPackages = with pkgs; [
      git
      adwaita-icon-theme
      mission-center
  ];
}
