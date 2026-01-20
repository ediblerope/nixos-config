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
    ./common.nix
  ];
}
