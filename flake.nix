{
  description = "FredOS NixOS configuration";
  inputs = {
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.11";
    home-manager-stable = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs-stable";
        home-manager.follows = "home-manager-stable";
      };
    };

    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";
  };
  outputs =
    { self
    , nixpkgs-stable
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
        FredOS-Gaming      = mkHost "FredOS-Gaming"      nixpkgs-stable home-manager-stable;
        FredOS-Mediaserver = mkHost "FredOS-Mediaserver" nixpkgs-stable home-manager-stable;
        FredOS-Macbook     = mkHost "FredOS-Macbook"     nixpkgs-stable home-manager-stable;
      };
    };
}
