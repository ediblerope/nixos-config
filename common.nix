# Common.nix
{ config, pkgs, lib, ... }:

{

imports = [
    ./common.nix
    ./hosts/FredOS-Gaming.nix
    ./hosts/FredOS-Macbook.nix
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
