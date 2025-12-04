# gnome.nix
{ config, pkgs, lib, ... }:

{
config = lib.mkIf (config.networking.hostName == "FredOS-Gaming" || config.networking.hostName == "FredOS-Macbook") {
	# Enable Gnome
	# Enable the X11 windowing system.
	services.xserver.enable = true;
	services.displayManager.gdm.enable = true;
	services.desktopManager.gnome.enable = true;
	
	# Add extensions
	# Add packages
	environment.systemPackages = with pkgs; [
		gnomeExtensions.blur-my-shell
		gnomeExtensions.just-perfection
		gnomeExtensions.appindicator
		gnomeExtensions.hot-edge
	];
};
}
