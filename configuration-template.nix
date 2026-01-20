# configuration-template.nix
####################################################################################################################################################################
## IMPORTANT: On a fresh NixOS install, run this command first:
nix-shell -p git --run "sudo nix-channel --add https://nixos.org/channels/nixos-unstable nixos && \
sudo nix-channel --add https://github.com/gmodena/nix-flatpak/archive/main.tar.gz nix-flatpak && \
sudo nix-channel --update && sudo nixos-rebuild switch"
####################################################################################################################################################################
{ config, pkgs, lib, ... }:
let
  gitConfig = builtins.fetchGit {
    url = "https://github.com/ediblerope/nixos-config";
    ref = "main";
  };
in
{
imports = [
  ./hardware-configuration.nix
  "${gitConfig}/common.nix"
];
networking.hostName = "HOSTNAME-HERE";  # Change this!
  
######################################################
## Add Nixos-default generated boot loader settings ##
######################################################
system.stateVersion = "25.11";
}
