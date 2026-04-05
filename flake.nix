{
  description = "FredOS NixOS configuration";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };
  
    nix-flatpak.url = "github:gmodena/nix-flatpak";
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";
  };
  outputs = { self, nixpkgs, home-manager, zen-browser, nix-flatpak, nix-cachyos-kernel, ... } @ inputs:
  let
    system = "x86_64-linux";
    mkHost = hostname: nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs; };
      modules = [
        ./hosts/${hostname}.nix
        ./hosts/hardware/${hostname}.nix 
        ./common.nix
        home-manager.nixosModules.home-manager
        nix-flatpak.nixosModules.nix-flatpak
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
