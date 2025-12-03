# Common.nix
{ config, pkgs, lib, ... }:

{
# Use latest kernel
boot.kernelPackages = pkgs.linuxPackages_latest;

# Shell aliases
environment.shellAliases = {
  update = "sudo nixos-rebuild switch --upgrade --option tarball-ttl 0";
  clean = "sudo nix-collect-garbage -d";  # Clean old generations
  ll = "ls -alh";
};

# Add packages
environment.systemPackages = [
	pkgs.git
];
 
# GNOME + Keybinds
# Enable the X11 windowing system.
services.xserver.enable = true;
services.displayManager.gdm.enable = true;
services.desktopManager.gnome.enable = true;
programs.dconf.enable = true;

programs.dconf = {
  enable = true;  # THIS WAS MISSING!
  profiles.user.databases = [{
    settings = {
      "org/gnome/settings-daemon/plugins/media-keys" = {
        home = "<Super>e";
        control-center = "<Super>i";
      };
      "org/gnome/desktop/wm/keybindings" = {
        close = [ "<Super>q" ];
      };
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
      };
    };
  }];
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

######################
##BORING STUFF BELOW##
######################
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

# Enable sound with pipewire.
services.pulseaudio.enable = false;
security.rtkit.enable = true;
services.pipewire = {
	enable = true;
	alsa.enable = true;
	alsa.support32Bit = true;
	pulse.enable = true;
};

# Configure keymap in X11
services.xserver.xkb = {
	layout = "gb";
	variant = "";
};
 
# Configure console keymap
console.keyMap = "uk";

}
