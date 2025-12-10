# gnome.nix
{ config, pkgs, lib, ... }:
{
config = lib.mkIf (config.networking.hostName == "FredOS-Gaming" || config.networking.hostName == "FredOS-Macbook") {
	# Enable Gnome
	services.xserver.enable = true;
	services.displayManager.gdm.enable = true;
	services.desktopManager.gnome.enable = true;
	
	# Add extensions and packages
	environment.systemPackages = with pkgs; [
		gnomeExtensions.blur-my-shell
		gnomeExtensions.just-perfection
		gnomeExtensions.appindicator
		gnomeExtensions.hot-edge
		gnomeExtensions.rounded-window-corners-reborn
		adwaita-icon-theme
		gnome-themes-extra  # This includes Adwaita cursor theme
	];
	
	# Set cursor theme
	environment.sessionVariables = {
		XCURSOR_THEME = "Adwaita";
		XCURSOR_SIZE = "24";
	};
	
	programs.xwayland.enable = true;
	programs.dconf.enable = true;
};
}
