# settings/home.nix
{ config, pkgs, ... }:
{
  # Define the state version for Home Manager
  home.stateVersion = "25.11";
  
  # --- Packages for the user ---
  # These are packages installed for the user only, not system-wide.
  home.packages = with pkgs; [
    #
  ];
  
  # --- Download wallpaper to home directory ---
  home.file.".local/share/backgrounds/wallpaper.jpg".source = pkgs.fetchurl {
    url = "https://share.nordhammer.it/api/shares/KCkDFACI/files/ffd480b9-4d9e-4410-8489-eb1c32e06307";
    sha256 = "1hbl4z3b43v9yh1i2dxz9wm52ff1hpv0kwck5afabifhh1b9nlz1";
  };
  
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
      picture-uri = "file:///home/fred/.local/share/backgrounds/wallpaper.jpg";
      picture-uri-dark = "file:///home/fred/.local/share/backgrounds/wallpaper.jpg";
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
  };
}
