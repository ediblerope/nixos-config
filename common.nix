# Common.nix
{ config, pkgs, lib, ... }:

{

imports = [
    ./settings/gnome.nix
	./settings/locale.nix
	./settings/audio.nix
    # Add all your hosts here
  ];

# Use latest kernel
boot.kernelPackages = pkgs.linuxPackages_latest;

# Shell aliases
environment.shellAliases = {
  update = "sudo nixos-rebuild switch --upgrade --option tarball-ttl 0";
  clean = "sudo nix-collect-garbage -d";  # Clean old generations
  ll = "ls -alh";
};

# Add packages
environment.systemPackages = with pkgs; [
	git
];

# Define a user account. Don't forget to set a password with ‘passwd’.
users.users.fred = {
    isNormalUser = true;
    description = "fred";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      bazaar
      fastfetch
    ];
  };

# Allow unfree packages
nixpkgs.config.allowUnfree = true;
 
# Services
services.flatpak.enable = true;

######################
##BORING STUFF BELOW##
######################
# Enable networking
networking.networkmanager.enable = true;

}
