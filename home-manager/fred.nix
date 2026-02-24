# settings/fred.nix
{ config, pkgs, lib, ... }:
{
  # Define the state version for Home Manager
  home.stateVersion = "25.11";
  
  # Packages for user
  home.packages = with pkgs; [
    #
  ];

  # Allow unfree nix-shell maybe
  nixpkgs.config.allowUnfree = true;
  
  # Import gnome home manager config
  imports = [ ./gnome-hm.nix ];
}
