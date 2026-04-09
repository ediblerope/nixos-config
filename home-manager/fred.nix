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
    font-family = MesloLGS Nerd Font
    font-size = 11
    font-thicken = true
    theme = dark:Catppuccin Mocha,light:Catppuccin Latte
    window-padding-x = 10
    window-padding-y = 10
    window-padding-balance = true
    background-opacity = 0.98
    confirm-close-surface = false
    gtk-titlebar = false
    cursor-style = bar
    cursor-style-blink = true
  '';

}
