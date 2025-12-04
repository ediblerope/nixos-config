# Common.nix
{ config, pkgs, lib, ... }:

{

imports = [
	./settings/gnome.nix
	./settings/locale.nix
	./settings/audio.nix
	./settings/users.nix
	./apps/fastfetch.nix
    # Add all your hosts here
  ];

# Use latest kernel
boot.kernelPackages = pkgs.linuxPackages_latest;

# Allow unfree packages
nixpkgs.config.allowUnfree = true;

# Services
services.flatpak.enable = true;

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
    sudo nixos-rebuild switch --upgrade --option tarball-ttl 0
  '';
  clean = "sudo nix-collect-garbage -d";
  ll = "ls -alh";
};

# Add packages
environment.systemPackages = with pkgs; [
	git
];



}
