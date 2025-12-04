########################################################################
# Template file used to set up git fetch. Run using 'nix-shell -p git' #
########################################################################


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

# Enable flakes for nix-unstable integration
nix.settings.experimental-features = [ "nix-command" "flakes" ];

####################################
## Space for boot loader settings ##
####################################
  system.stateVersion = "25.11";
}
