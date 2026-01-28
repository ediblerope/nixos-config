{ config, pkgs, lib, osConfig, ... }:
{
  config = lib.mkIf (lib.elem osConfig.networking.hostName [ "FredOS-Gaming" "FredOS-Macbook" ]) {
    # Download wallpaper from GitHub repo and symlink it
    home.file.".local/share/backgrounds/wallpaper.png".source = 
      let
        wallpaperRepo = builtins.fetchGit {
          url = "https://github.com/ediblerope/nixos-config";
          ref = "main";
        };
      in "${wallpaperRepo}/walls/wallpaper.png";
    
    # GNOME dconf settings
    dconf.settings = {
      # Interface / theme
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        gtk-theme = "Adwaita-dark";
        enable-hot-corners = false;
        accent-color = "purple";
        cursor-theme = "Adwaita";
        cursor-size = 24;
      };
      
      # Wallpaper settings
      "org/gnome/desktop/background" = {
        picture-uri = "file://${config.home.homeDirectory}/.local/share/backgrounds/wallpaper.png";
        picture-uri-dark = "file://${config.home.homeDirectory}/.local/share/backgrounds/wallpaper.png";
        picture-options = "zoom";
      };
      
      # Keyboard input sources
      "org/gnome/desktop/input-sources" = {
        sources = [
          (lib.hm.gvariant.mkTuple [ "xkb" "gb" ])
          (lib.hm.gvariant.mkTuple [ "xkb" "no" ])
        ];
      };
      
      # Window manager keybindings
      "org/gnome/desktop/wm/keybindings" = {
        close = ["<Super>q"];
        toggle-fullscreen = ["<Super>f"];
      };
      "org/gnome/desktop/wm/preferences" = {
        resize-with-right-button = lib.hm.gvariant.mkBoolean true;
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
      
      # Just Perfection extension
      "org/gnome/shell/extensions/just-perfection" = {
        window-demands-attention-focus = true;
      };
      
      # Rounded Window Corners extension
      #"org/gnome/shell/extensions/rounded-window-corners-reborn" = let
      #  mkUint32 = lib.hm.gvariant.mkUint32;
      #  mkVariant = lib.hm.gvariant.mkVariant;
      #  mkTuple = lib.hm.gvariant.mkTuple;
      #  mkEntry = name: value: lib.hm.gvariant.mkDictionaryEntry [name value];
      #  mkDict = attrs: mkVariant (
      #    lib.mapAttrsToList (name: value: mkEntry name value) attrs
      #  );
      #in {
      #  global-rounded-corner-settings = [
      #    (mkEntry "padding" (mkDict {
      #      left = mkUint32 4;
      #      right = mkUint32 4;
      #      top = mkUint32 4;
      #      bottom = mkUint32 4;
      #    }))
      #    (mkEntry "keepRoundedCorners" (mkDict {
      #      maximized = true;
      #      fullscreen = true;
      #    }))
      #    (mkEntry "borderRadius" (mkVariant (mkUint32 7)))
      #    (mkEntry "smoothing" (mkVariant 0.0))
      #    (mkEntry "borderColor" (mkVariant (mkTuple [ 0.5 0.5 0.5 1.0 ])))
      #    (mkEntry "enabled" (mkVariant true))
      #  ];
      #};
    };
  };
}
