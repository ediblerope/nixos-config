{
  inputs = {
    omnisearch = {
      url = "git+https://git.bwaaa.monster/omnisearch";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, omnisearch, ... }: {
    nixosConfigurations.mySystem = nixpkgs.lib.nixosSystem {
      modules = [
        omnisearch.nixosModules.default
        {
          services.omnisearch.enable = true;
        }
      ];
    };
  };
}