{ config, pkgs, lib, osConfig, inputs, ... }:
{
  config = lib.mkIf (lib.elem osConfig.networking.hostName [ "FredOS-Gaming" "FredOS-Macbook" ]) {

    home.file.".local/share/backgrounds/wallpaper.png".source = 
      "${inputs.self}/walls/wallpaper.png";
    
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
