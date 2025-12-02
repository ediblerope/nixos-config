{ config, pkgs, lib, ... }:

{
imports = [
	./hardware-configuration.nix
	./base.nix
];

# Bootloader.
boot.loader.grub.enable = true;
boot.loader.grub.device = "/dev/vda";
boot.loader.grub.useOSProber = true;

networking.hostName = "FredOS-gaming";

system.stateVersion = "25.11";

}
