{ config, lib, pkgs, ... }:

{

environment.systemPackages = with pkgs; [
	appeditor
	git
	vlc
	spotify
	heroic
	jellyfin
	jellyfin-web
	jellyfin-ffmpeg
	qbittorrent
	google-chrome
	wayland-utils # Wayland utilities
	wl-clipboard # Command-line copy/paste utilities for Wayland
	appimage-run
	kdePackages.kcalc # Calculator
	kdePackages.kate #text editor
	kdePackages.dolphin
	font-awesome
	gpu-screen-recorder
	gpu-screen-recorder-gtk
	discord
	asciiquarium
	cargo
	ventoy-full-gtk
	popsicle
];

nixpkgs.config.permittedInsecurePackages = [
"ventoy-gtk3-1.1.05"
];


}


