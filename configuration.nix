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
    "${gitConfig}/git.nix"
  ];
  
  networking.hostName = "FredOS-Gaming";
  
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";
  boot.loader.grub.useOSProber = true;
  
  system.stateVersion = "25.11";
}
