{ config, pkgs, ... }:

let
  # Fetch your config from GitHub
  gitConfig = builtins.fetchGit {
    url = "https://github.com/ediblerope/nixos-config";
    ref = "main";
  };
in
{
  imports = [
    ./hardware-configuration.nix  # This stays local (machine-specific)
    "${gitConfig}/git.nix"        # Your main config from GitHub
  ];

  # ONLY thing that changes per machine
  networking.hostName = "";  # Change this per machine
  
  system.stateVersion = "25.11";
}
