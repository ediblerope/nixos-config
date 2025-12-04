# flake.nix (New File)
{
  description = "Fred's NixOS Flake";

  inputs = {
    # 1. NixOS unstable (Replaces your 'nixos-unstable' channel)
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # 2. Home Manager master (Replaces your 'home-manager master' channel)
    home-manager = {
      url = "github:nix-community/home-manager/master";
      # Ensure Home Manager uses the Nixpkgs input defined above
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }: {
    # Define your single NixOS configuration
    nixosConfigurations.FredOS-Gaming = nixpkgs.lib.nixosSystem {
      # Use the unstable system
      system = "x86_64-linux";
      
      # Import your existing configurations
      modules = [
        # This is where you point to your existing common.nix
        ./common.nix 
        
        # 🌟 NEW: Home Manager module inclusion 🌟
        # You declare HM as a module here instead of using the imports in common.nix
        # NOTE: You MUST remove the imports block for Home Manager from common.nix!
        home-manager.nixosModules.home-manager
      ];
    };
  };
}
