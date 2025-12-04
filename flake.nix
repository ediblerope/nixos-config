# flake.nix (New File)
{
  description = "Fred's NixOS Flake";

  inputs = {
    # NixOS unstable
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Home Manager master
    home-manager = {
      url = "github:nix-community/home-manager/master";
      # Ensure Home Manager uses the Nixpkgs input defined above
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }: {
    nixosConfigurations.FredOS-Gaming = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./common.nix 
        home-manager.nixosModules.home-manager
      ];
    };
  };
}
