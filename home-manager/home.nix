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
    "org/gnome/shell/extensions/rounded-window-corners-reborn" = {
      global-rounded-corner-settings = {
        # 1. Padding: A Variant containing a Dictionary of Uint32s
        padding = lib.hm.gvariant.mkVariant {
          left = lib.hm.gvariant.mkUint32 2;
          right = lib.hm.gvariant.mkUint32 2;
          top = lib.hm.gvariant.mkUint32 2;
          bottom = lib.hm.gvariant.mkUint32 2;
        };

        # 2. Keep Corners: A Variant containing a Dictionary of Booleans
        keepRoundedCorners = lib.hm.gvariant.mkVariant {
          maximized = true;
          fullscreen = true;
        };

        # 3. Border Radius: A Variant containing a Uint32
        borderRadius = lib.hm.gvariant.mkVariant (lib.hm.gvariant.mkUint32 7);

        # 4. Smoothing: A Variant containing a Double
        smoothing = lib.hm.gvariant.mkVariant 0.0;

        # 5. Border Color: A Variant containing a Tuple of Doubles
        borderColor = lib.hm.gvariant.mkVariant (lib.hm.gvariant.mkTuple [ 0.5 0.5 0.5 1.0 ]);

        # 6. Enabled: A Variant containing a Boolean
        enabled = lib.hm.gvariant.mkVariant true;
      };
    };
  };
}
