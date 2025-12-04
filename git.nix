# git.nix
{ config, pkgs, lib, ... }:

{
  imports = [
    #./flake.nix
    ./hosts/FredOS-Gaming.nix
    ./hosts/FredOS-Macbook.nix
    # Add all your hosts here
  ];
}
