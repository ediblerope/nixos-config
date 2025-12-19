# git.nix
{ config, pkgs, lib, ... }:
let
  home-manager = builtins.fetchTarball {
    url = "https://github.com/nix-community/home-manager/archive/master.tar.gz";
  };
in
{
  imports = [
    (import "${home-manager}/nixos")
    ./hosts/FredOS-Gaming.nix
    ./hosts/FredOS-Macbook.nix
    ./common.nix
  ];
  
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.fred = import ./home-manager/fred.nix;
}
