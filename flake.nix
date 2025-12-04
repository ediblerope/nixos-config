# flake.nix
{
  description = "Fred's NixOS Flake";
  
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  
  outputs = { self, nixpkgs, home-manager, ... }: {
    nixosConfigurations.FredOS-Gaming = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./hosts/FredOS-Gaming.nix  # Main host config
        ./hosts/FredOS-Macbook.nix # Macbook config
        ./common.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.fred = import ./home.nix;  # You'll need to create this
        }
      ];
    };
  };
}
