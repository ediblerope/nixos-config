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
	gnomeExtensions.blur-my-shell
	gnomeExtensions.just-perfection
	gnomeExtensions.appindicator
	gnomeExtensions.hot-edge
];
 
# GNOME + Keybinds
# Enable the X11 windowing system.
services.xserver.enable = true;
services.displayManager.gdm.enable = true;
services.desktopManager.gnome.enable = true;


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
