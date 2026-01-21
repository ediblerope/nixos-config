{ config, pkgs, lib, ... }:
{
	config = lib.mkIf (config.networking.hostName == "FredOS-Mediaserver") {
		inputs = {
		    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
		    sops-nix.url = "github:Mic92/sops-nix";
		  };
		
		  outputs = { self, nixpkgs, sops-nix }: {
		    nixosConfigurations.yourhostname = nixpkgs.lib.nixosSystem {
		      modules = [
		        sops-nix.nixosModules.sops
		        ./configuration.nix
		      ];
		    };
		};
	};
}
