{ config, pkgs, lib, osConfig, inputs, ... }:
{
  config = lib.mkIf (lib.elem osConfig.networking.hostName [ "FredOS-Gaming" "FredOS-Macbook" ]) {

    home.file.".local/share/backgrounds/wallpaper.png".source =
      "${inputs.self}/walls/wallpaper.png";

    # Minimal titlebars — hide window buttons and shrink headerbar
    home.file.".config/gtk-4.0/gtk.css".force = true;
    home.file.".config/gtk-4.0/gtk.css".text = ''
      headerbar {
        min-height: 0;
        padding: 0;
        margin: 0;
      }
      headerbar .title {
        font-size: 0;
      }
    '';
    home.file.".config/gtk-3.0/gtk.css".force = true;
    home.file.".config/gtk-3.0/gtk.css".text = ''
      headerbar {
        min-height: 0;
        padding: 0;
        margin: 0;
      }
      headerbar .title {
        font-size: 0;
      }
    '';
    
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
        button-layout = "";
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
        command = "ghostty";
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
    };
  };
}
