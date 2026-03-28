{
  description = "FredOS NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    omnisearch = {
      url = "git+https://git.bwaaa.monster/omnisearch";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-flatpak.url = "github:gmodena/nix-flatpak";
  };

  outputs = { self, nixpkgs, home-manager, omnisearch, zen-browser, nix-flatpak, ... } @ inputs:
  let
    system = "x86_64-linux";
    mkHost = hostname: nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs; };
      modules = [
        ./hosts/${hostname}.nix
        ./common.nix
        home-manager.nixosModules.homeManager
        nix-flatpak.nixosModules.nix-flatpak
        omnisearch.nixosModules.default
      ];
    };
  in {
    nixosConfigurations = {
      FredOS-Gaming      = mkHost "FredOS-Gaming";
      FredOS-Mediaserver = mkHost "FredOS-Mediaserver";
      FredOS-Macbook     = mkHost "FredOS-Macbook";
    };
  };
}