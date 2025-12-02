{ config, pkgs, lib, ... }:

{
  imports = [
    ./common.nix
  ] ++ lib.optional (builtins.pathExists ./hosts/${config.networking.hostName}.nix)
    ./hosts/${config.networking.hostName}.nix;
}
