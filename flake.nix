# flake.nix — place this in the root of your nixos-config repo
{
  description = "FredOS NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";  # shares your nixpkgs, no double download
    };

    omnisearch = {
      url = "git+https://git.bwaaa.monster/omnisearch/omnisearch";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-flatpak = {
      url = "github:gmodena/nix-flatpak";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, omnisearch, zen-browser, nix-flatpak, ... } @ inputs:
  let
    system = "x86_64-linux";

    # Helper so each host doesn't have to repeat the boilerplate
    mkHost = hostname: nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs; };  # makes 'inputs' available in all your .nix files
      modules = [
        ./hosts/${hostname}.nix          # your existing per-host file
        ./common.nix                     # your existing shared config
        home-manager.nixosModules.homeManager
        nix-flatpak.nixosModules.nix-flatpak
      ];
    };
  in {
    nixosConfigurations = {
      FredOS-Gaming       = mkHost "FredOS-Gaming";
      FredOS-Mediaserver  = mkHost "FredOS-Mediaserver";
      FredOS-Macbook      = mkHost "FredOS-Macbook";
    };
  };
}