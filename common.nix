{ config, pkgs, lib, ... }:

{

boot.kernelPackages = pkgs.linuxPackages_latest;
 
# Enable networking
networking.networkmanager.enable = true;
 
# Set your time zone.
time.timeZone = "Europe/London";
 
# Select internationalisation properties.
i18n.defaultLocale = "en_GB.UTF-8";
i18n.extraLocaleSettings = {
	LC_ADDRESS = "en_GB.UTF-8";
	LC_IDENTIFICATION = "en_GB.UTF-8";
	LC_MEASUREMENT = "en_GB.UTF-8";
	LC_MONETARY = "en_GB.UTF-8";
	LC_NAME = "en_GB.UTF-8";
	LC_NUMERIC = "en_GB.UTF-8";
	LC_PAPER = "en_GB.UTF-8";
	LC_TELEPHONE = "en_GB.UTF-8";
	LC_TIME = "en_GB.UTF-8";
};
 
# GNOME
# Enable the X11 windowing system.
services.xserver.enable = true;
services.displayManager.gdm.enable = true;
services.desktopManager.gnome.enable = true;
 
# Configure keymap in X11
services.xserver.xkb = {
	layout = "gb";
	variant = "";
};
 
# Configure console keymap
console.keyMap = "uk";
 
# Enable sound with pipewire.
services.pulseaudio.enable = false;
security.rtkit.enable = true;
services.pipewire = {
	enable = true;
	alsa.enable = true;
	alsa.support32Bit = true;
	pulse.enable = true;
};

# Define a user account. Don't forget to set a password with ‘passwd’.
users.users.fred = {
	isNormalUser = true;
	description = "fred";
	extraGroups = [ "networkmanager" "wheel" ];
	packages = with pkgs; [
		bazaar
		fastfetch
		vesktop
	];
};
 
# Allow unfree packages
nixpkgs.config.allowUnfree = true;
 
# Services
services.flatpak.enable = true;
}
