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
		openssh.authorizedKeys.keys = [
			"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEOgQQ9aO8Ri5oL2c3QntSk05PkryfLNsJQqIcjfKFqL fredrik@nordhammer.it" # FredOS-Gaming
			"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILTLAr9hSWW5PerZJmDZwmB5sa0DBTe2mM4IwTtcCfX3 fredrik@nordhammer.it" # phone
		];
	};
}
