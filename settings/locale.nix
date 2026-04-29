# locale.nix
{ config, pkgs, lib, ... }:

{
# Static timezone — automatic-timezoned needs polkit rules to call timedate1
# and was failing on every host. Override on the laptop if it ever moves.
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

# Configure keymap in X11
services.xserver.xkb = {
	layout = "gb";
	variant = "";
};
 
# Configure console keymap
console.keyMap = "uk";

}
