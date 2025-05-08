# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

let 
  username = "fred";
in

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

##########################
# Macbook required setup #
##########################
nixpkgs.config.allowUnfree = true;
boot.kernelModules = [ "wl" ];
boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];
networking.networkmanager.enable = true;
networking.wireless.enable = false;

###################
# System settings #
###################
i18n.defaultLocale = "en_GB.UTF-8";
time.timeZone = "Europe/London";

##################
# Hardware setup #
##################

###############
# Boot loader #
###############
boot.loader = {
	systemd-boot.enable = true;
	efi = {
		canTouchEfiVariables = true;
		efiSysMountPoint = "/boot/efi";
	};
};

##############
# User setup #
##############
users.users.fred = { isNormalUser = true; initialPassword = "123"; extraGroups = [ "wheel" "networkmanager" ];};

system.activationScripts.fix-nixos-perms = ''
    chown -R ${username}:users /etc/nixos/.git
    chmod -R g+rw /etc/nixos/.git
  '';
  
#############
# git setup #
#############
environment.etc."gitconfig".text = ''
  [safe]
    directory = /etc/nixos
'';

########################
# User personalisation #
########################

# GNOME
services.xserver = {
	enable = true;
	displayManager.gdm.enable = true;
	desktopManager.gnome.enable = true;
};

environment.gnome.excludePackages = (with pkgs; [
	geary # email reader
	gnome-music
	gnome-photos
	gnome-tour
	gnome-calendar
	gnome-weather
	gnome-clocks
	gnome-contacts
	gnome-maps
	pkgs.gnome-connections
	simple-scan
	yelp
	totem # video player
]);

# systemPackages
environment.systemPackages = with pkgs; [
	discord-ptb
	git
];

# Steam
programs.steam = {
	enable = true;
};

system.stateVersion = "24.11";
}
