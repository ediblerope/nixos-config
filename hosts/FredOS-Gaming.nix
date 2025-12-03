{ config, pkgs, lib, ... }:

{
config = lib.mkIf (config.networking.hostName == "FredOS-Gaming") {
	
	# List packages installed in system profile. To search, run:
	# $ nix search wget
	environment.systemPackages = with pkgs; [
		#Package name
		lutris
	];
	programs.steam = {
	enable = true;
	remotePlay.openFirewall = true;
	package = pkgs.steam.override {
        extraPkgs =
          pkgs: with pkgs; [
            kdePackages.breeze
          ];
	};
};
	
};
}
