{ config, lib, pkgs, ... }:

let
  username = "fred";
in

{

# Base setup
nixpkgs.config.allowUnfree = true; #required for Steam
networking.networkmanager.enable = true;
networking.wireless.enable = false;

# Locale
i18n.defaultLocale = "en_GB.UTF-8";
time.timeZone = "Europe/London";
services.xserver = {
	xkb.layout = "no";
};

# Install home manager
#environment.systemPackages = with pkgs; [
#	home-manager
#];

# Home Manager configuration
#home-manager = {
  #useGlobalPkgs = true;    # Use system-wide packages
  #useUserPackages = true;   # Install packages to user profile
  #users.fred = import ./home.nix;  # Your personal config
#};

# Base user setup
users.users.fred = { isNormalUser = true; initialPassword = "123"; extraGroups = [ "wheel" "networkmanager" "audio" ];};

# Give perms for nixos folder so git can run without sudo
#system.activationScripts.fix-nixos-perms = ''
#    chown -R ${username}:users /etc/nixos/.git
#    chmod -R g+rw /etc/nixos/.git
#  '';

#environment.etc."gitconfig".text = ''
#  [safe]
#    directory = /etc/nixos
#'';

#Fonts?
fonts.packages = with pkgs; [ font-awesome ];


}
