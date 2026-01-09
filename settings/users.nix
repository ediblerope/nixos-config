# users.nix
{ config, pkgs, lib, ... }:

{
	config = lib.mkIf (lib.elem config.networking.hostName [ "FredOS-Gaming" "FredOS-Macbook" ]) {
	    # Define a user account. Don't forget to set a password with 'passwd'.
		users.users.fred = {
			isNormalUser = true;
			description = "fred";
			extraGroups = [ "networkmanager" "wheel" ];
			packages = with pkgs; [
				bazaar
				fastfetch
			];
		};
	};
}
