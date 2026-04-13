# settings/fred.nix
{ config, pkgs, lib, inputs, ... }:
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
  
  # Ensure Ghostty themes directory exists for matugen
  home.file.".config/ghostty/themes/.keep".text = "";

  # Ghostty config
  home.file.".config/ghostty/config".force = true;
  home.file.".config/ghostty/config".text = ''
    font-family = FiraMono Nerd Font
    font-size = 11
    font-thicken = true
    theme = wallpaper
    window-padding-x = 10
    window-padding-y = 10
    window-padding-balance = true
    background-opacity = 0.98
    confirm-close-surface = false
    gtk-titlebar = false
    cursor-style = bar
    cursor-style-blink = true
  '';

  # Matugen config — templates for wallpaper-based color generation
  home.file.".config/matugen/config.toml".text = ''
    [config]
    reload_apps = true
    reload_apps_list = { ghostty = "" }

    [templates.ghostty]
    input_path = "${inputs.self}/templates/ghostty-colors"
    output_path = "${config.home.homeDirectory}/.config/ghostty/themes/wallpaper"

    [templates.gtk4]
    input_path = "${inputs.self}/templates/gtk4-colors.css"
    output_path = "${config.home.homeDirectory}/.config/gtk-4.0/colors.css"

    [templates.recolor-folders]
    input_path = "${inputs.self}/templates/recolor-folders.sh"
    output_path = "${config.home.homeDirectory}/.local/share/matugen/recolor-folders.sh"
    post_hook = "bash ${config.home.homeDirectory}/.local/share/matugen/recolor-folders.sh"
  '';

}
