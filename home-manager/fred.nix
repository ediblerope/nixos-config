# settings/fred.nix
{ config, pkgs, lib, ... }:  # Add lib here!
{
  # Define the state version for Home Manager
  home.stateVersion = "25.11";
  
  # Packages for user
  home.packages = with pkgs; [
    #
  ];
  
}
