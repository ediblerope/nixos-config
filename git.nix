# git.nix
{ config, pkgs, lib, ... }:

{
  imports = [
    ./common.nix
    ./hosts/FredOS-Gaming.nix
    ./hosts/laptop.nix
    # Add all your hosts here
  ];
}
