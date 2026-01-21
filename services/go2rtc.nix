{ config, pkgs, lib, ... }:

let
  sops-nix = builtins.fetchTarball {
    url = "https://github.com/Mic92/sops-nix/archive/master.tar.gz";
  };
in

{
	imports = [
		"${sops-nix}/modules/sops"
	];

	config = lib.mkIf (config.networking.hostName == "FredOS-Mediaserver") {
		
		
		
		
	};
}
