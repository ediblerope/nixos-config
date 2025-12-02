{ config, pkgs, ... }:

{
  imports = [
    ./common.nix
    ./hosts/${config.networking.hostName}.nix
  ];
}
