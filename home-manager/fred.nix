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
  home.file.".config/nixpkgs/config.nix".text = ''
    { allowUnfree = true; }
  '';
  
  # Ghostty config
  home.file.".config/ghostty/config".force = true;
  home.file.".config/ghostty/config".text = ''
    font-family = FiraCode Nerd Font
    font-size = 11
    theme = dark:Catppuccin Mocha,light:Catppuccin Latte
    window-padding-x = 10
    window-padding-y = 10
    confirm-close-surface = false
    gtk-titlebar = false
  '';

  # Import gnome home manager config
  imports = [ ./gnome-hm.nix ];
}
