# settings/fred.nix
{ config, pkgs, lib, inputs, osConfig, ... }:
let
  isDesktop = lib.elem osConfig.networking.hostName [ "FredOS-Gaming" "FredOS-Macbook" ];
in
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

  # Wallpaper — source of truth for matugen on all hosts
  home.file.".local/share/backgrounds/wallpaper.png".source =
    "${inputs.self}/walls/wallpaper.png";

  # Ensure Ghostty themes directory exists for matugen
  home.file.".config/ghostty/themes/.keep".text = "";

  # btop config — use matugen-generated theme
  home.file.".config/btop/btop.conf".force = true;
  home.file.".config/btop/btop.conf".text = ''
    color_theme = "matugen"
    theme_background = False
    vim_keys = False
  '';
  home.file.".config/btop/themes/.keep".text = "";

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

    [templates.btop]
    input_path = "${inputs.self}/templates/btop.theme"
    output_path = "${config.home.homeDirectory}/.config/btop/themes/matugen.theme"
  '' + lib.optionalString isDesktop ''

    [templates.ghostty]
    input_path = "${inputs.self}/templates/ghostty-colors"
    output_path = "${config.home.homeDirectory}/.config/ghostty/themes/wallpaper"

    [templates.gtk4]
    input_path = "${inputs.self}/templates/gtk4-colors.css"
    output_path = "${config.home.homeDirectory}/.config/gtk-4.0/colors.css"

    [templates.gtk3]
    input_path = "${inputs.self}/templates/gtk3-colors.css"
    output_path = "${config.home.homeDirectory}/.config/gtk-3.0/colors.css"

    [templates.gnome-shell]
    input_path = "${inputs.self}/templates/gnome-shell.css"
    output_path = "${config.home.homeDirectory}/.local/share/themes/WallpaperShell/gnome-shell/gnome-shell.css"

    [templates.zen]
    input_path = "${inputs.self}/templates/zen-userChrome.css"
    output_path = "${config.home.homeDirectory}/.zen/fraudek5.Default Profile/chrome/userChrome.css"

    [templates.vscodium]
    input_path = "${inputs.self}/templates/vscodium-colors.json"
    output_path = "${config.home.homeDirectory}/.local/share/matugen/vscodium-colors.json"
    post_hook = "jq -s '.[0] * .[1]' ${config.home.homeDirectory}/.config/VSCodium/User/settings.json ${config.home.homeDirectory}/.local/share/matugen/vscodium-colors.json > ${config.home.homeDirectory}/.config/VSCodium/User/settings.json.tmp && mv ${config.home.homeDirectory}/.config/VSCodium/User/settings.json.tmp ${config.home.homeDirectory}/.config/VSCodium/User/settings.json"

    [templates.vesktop]
    input_path = "${inputs.self}/templates/vesktop-quickCss.css"
    output_path = "${config.home.homeDirectory}/.config/vesktop/settings/quickCss.css"

    [templates.recolor-folders]
    input_path = "${inputs.self}/templates/recolor-folders.sh"
    output_path = "${config.home.homeDirectory}/.local/share/matugen/recolor-folders.sh"
    post_hook = "bash ${config.home.homeDirectory}/.local/share/matugen/recolor-folders.sh"
  '' + lib.optionalString (osConfig.networking.hostName == "FredOS-Mediaserver") ''

    [templates.homepage]
    input_path = "${inputs.self}/templates/homepage.css"
    output_path = "/var/lib/homepage-custom-css/custom.css"
  '';

}
