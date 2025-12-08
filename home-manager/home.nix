# settings/home.nix
{ config, pkgs, lib, ... }:  # Add lib here!
{
  # Define the state version for Home Manager
  home.stateVersion = "25.11";
  
  # --- Packages for the user ---
  home.packages = with pkgs; [
    #
  ];
  
  # --- Download wallpaper from your GitHub repo ---
  home.file.".local/share/backgrounds/wallpaper.png".source = 
    "${builtins.fetchGit {
      url = "https://github.com/ediblerope/nixos-config";
      ref = "main";
    }}/walls/wallpaper.png";
  
  # --- GNOME/dconf Settings via Home Manager ---
  dconf.settings = {
    # Interface / theme
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      gtk-theme = "Adwaita-dark";
      enable-hot-corners = false;
      accent-color = "purple";
    };
    
    # Wallpaper settings
    "org/gnome/desktop/background" = {
      picture-uri = "file://${config.home.homeDirectory}/.local/share/backgrounds/wallpaper.png";
      picture-uri-dark = "file://${config.home.homeDirectory}/.local/share/backgrounds/wallpaper.png";
      picture-options = "zoom";
    };
    
    # Window manager keybindings
    "org/gnome/desktop/wm/keybindings" = {
      close = ["<Super>q"];
      toggle-fullscreen = ["<Super>f"];
    };
    
    # Shell keybindings
    "org/gnome/shell/keybindings" = {
      show-screenshot-ui = ["<Shift><Super>s"];
    };
    
    # Custom keybindings
    "org/gnome/settings-daemon/plugins/media-keys" = {
      home = ["<Super>e"];
      control-center = ["<Super>i"];
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
      ];
    };
    
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      name = "Terminal";
      command = "kgx";
      binding = "<Super>t";
    };
    
    # Mouse acceleration
    "org/gnome/desktop/peripherals/mouse" = {
      accel-profile = "flat";
    };
    
    # Rounded Window Corners extension
    "org/gnome/shell/extensions/rounded-window-corners-reborn/global-rounded-corner-settings" = {
    padding = lib.hm.gvariant.mkDictionaryEntry [
      (lib.hm.gvariant.mkDictionaryEntry [ "left" (lib.hm.gvariant.mkUint32 2) ])
      (lib.hm.gvariant.mkDictionaryEntry [ "right" (lib.hm.gvariant.mkUint32 2) ])
      (lib.hm.gvariant.mkDictionaryEntry [ "top" (lib.hm.gvariant.mkUint32 2) ])
      (lib.hm.gvariant.mkDictionaryEntry [ "bottom" (lib.hm.gvariant.mkUint32 2) ])
    ];
    keepRoundedCorners = lib.hm.gvariant.mkDictionaryEntry [
      (lib.hm.gvariant.mkDictionaryEntry [ "maximized" true ])
      (lib.hm.gvariant.mkDictionaryEntry [ "fullscreen" true ])
    ];
    borderRadius = lib.hm.gvariant.mkUint32 7;
    smoothing = 0.0;
    enabled = true;
  };
  };
}
