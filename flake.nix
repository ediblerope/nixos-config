{
  description = "FredOS NixOS configuration";
  inputs = {
    # Unstable: gaming desktop & laptop want bleeding-edge GPU/kernel updates.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # Stable: mediaserver values cache hit-rate over fresh packages so it
    # doesn't have to compile gnupg/openldap/v8 locally on every flake bump.
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.11";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager-stable = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };

    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";
  };
  outputs =
    { self
    , nixpkgs
    , nixpkgs-stable
    , home-manager
    , home-manager-stable
    , zen-browser
    , nix-cachyos-kernel
    , ...
    } @ inputs:
    let
      system = "x86_64-linux";
      mkHost = hostname: pkgsInput: hmInput: pkgsInput.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/${hostname}.nix
          ./hosts/hardware/${hostname}.nix
          ./common.nix
          hmInput.nixosModules.home-manager
        ];
      };
    in
    {
      nixosConfigurations = {
        FredOS-Gaming      = mkHost "FredOS-Gaming"      nixpkgs        home-manager;
        FredOS-Mediaserver = mkHost "FredOS-Mediaserver" nixpkgs-stable home-manager-stable;
        FredOS-Macbook     = mkHost "FredOS-Macbook"     nixpkgs-stable home-manager-stable;
      };
    };
}
