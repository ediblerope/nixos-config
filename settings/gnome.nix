{ config, pkgs, lib, inputs, ... }:
{
  config = lib.mkIf (lib.elem config.networking.hostName [ "FredOS-Gaming" "FredOS-Macbook" ]) {
    # Enable Gnome
    services.xserver.enable = true;
    services.displayManager.gdm.enable = true;
    services.desktopManager.gnome.enable = true;
    services.displayManager.gdm.wayland = true;
    boot.plymouth.enable = false;

    # Flatpak for ad-hoc app installs via Bazaar
    services.flatpak.enable = true;

    # Add extensions, packages, and terminal
    environment.systemPackages = with pkgs; [
      ghostty
      gnomeExtensions.blur-my-shell
      gnomeExtensions.just-perfection
      gnomeExtensions.appindicator
      gnomeExtensions.hot-edge
      #gnomeExtensions.rounded-window-corners-reborn
      adwaita-icon-theme
      gnome-themes-extra
      morewaita-icon-theme
      adw-gtk3
      matugen
    ];

    # Set cursor theme
    environment.sessionVariables = {
      XCURSOR_THEME = "Adwaita";
      XCURSOR_SIZE = "24";
      XCURSOR_PATH = lib.mkForce [
        "${pkgs.adwaita-icon-theme}/share/icons"
        "$HOME/.icons"
        "$HOME/.local/share/icons"
      ];
    };

    # Set icon theme via dconf
    programs.dconf.profiles.user.databases = [{
      settings = {
        "org/gnome/desktop/interface" = {
          icon-theme = "MoreWaita";
          cursor-theme = "Adwaita";
        };
        "org/gnome/mutter" = {
          experimental-features = [ "variable-refresh-rate" ];
        };
      };
    }];

    qt = {
      enable = true;
      platformTheme = "gnome";
      style = "adwaita-dark";
    };

    programs.xwayland.enable = true;
    programs.dconf.enable = true;

    # Home Manager GNOME settings
    home-manager.users.fred = { config, lib, ... }: {
      home.file.".local/share/backgrounds/wallpaper.png".source =
        "${inputs.self}/walls/wallpaper.png";

      # Minimal titlebars — hide window buttons and shrink headerbar
      home.file.".config/gtk-4.0/gtk.css".force = true;
      home.file.".config/gtk-4.0/gtk.css".text = ''
        @import url("colors.css");
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
          gtk-theme = "adw-gtk3-dark";
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
  };
}
