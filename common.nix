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

# Enable networking
networking.networkmanager.enable = true;

# Shell aliases
#environment.shellAliases = {
#  update = "sudo nixos-rebuild switch --upgrade --option tarball-ttl 0";
#  clean = "sudo nix-collect-garbage -d";  # Clean old generations
#  ll = "ls -alh";
#};

# Add packages
environment.systemPackages = with pkgs; [
	git
];



}
