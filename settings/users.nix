# users.nix
{ config, pkgs, lib, ... }:

{
    # Define a user account. Don't forget to set a password with 'passwd'.
	users.users.fred = {
		isNormalUser = true;
		description = "fred";
		extraGroups = [ "networkmanager" "wheel" "docker" ];
		packages = with pkgs; [
			bazaar
		];
	};
}
