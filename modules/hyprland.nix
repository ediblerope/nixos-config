{ config, lib, pkgs, ... }:

{
programs.hyprland= {
	enable = true; # enable Hyprland
	xwayland.enable = true;
};


environment.systemPackages = with pkgs; [
	wofi
	hyprpaper
	waybar
	hyprlock
	kitty
	libnotify
	swaynotificationcenter
	nerd-fonts.zed-mono
];
}
