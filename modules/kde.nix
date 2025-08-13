{ config, lib, pkgs, ... }:

{
# Enable SDDM with Wayland support
services.displayManager = {
	sddm = {
		enable = true;
		wayland.enable = true;  # Force Wayland mode
	};
};


# Enable Plasma with Wayland
services.desktopManager.plasma6.enable = true;

environment.systemPackages = with pkgs; [
	kdePackages.kcalc # Calculator
	kdePackages.kcharselect # Tool to select and copy special characters from all installed fonts
	kdePackages.kcolorchooser # A small utility to select a color
	kdePackages.kolourpaint # Easy-to-use paint program
	kdePackages.ksystemlog # KDE SystemLog Application
	kdePackages.sddm-kcm # Configuration module for SDDM
	kdePackages.kate #text editor
	kdePackages.krunner
	libnotify
	xsettingsd
	xorg.xrdb
];

}
