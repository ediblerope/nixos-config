{ config, pkgs, lib, ... }:
{
  config = lib.mkIf (lib.elem config.networking.hostName [ "FredOS-Gaming" "FredOS-Macbook" ]) {
    # Enable Gnome
    services.xserver.enable = true;
    services.displayManager.gdm.enable = true;
    services.desktopManager.gnome.enable = true;
    services.displayManager.gdm.wayland = true;
    boot.plymouth.enable = false;
    
    # Add extensions and packages
    environment.systemPackages = with pkgs; [
      gnomeExtensions.blur-my-shell
      gnomeExtensions.just-perfection
      gnomeExtensions.appindicator
      gnomeExtensions.hot-edge
      gnomeExtensions.rounded-window-corners-reborn
      gnomeExtensions.hide-top-bar
      adwaita-icon-theme
      gnome-themes-extra
      papirus-icon-theme
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
          icon-theme = "Papirus";
          cursor-theme = "Adwaita";
        };
      };
    }];
    
    programs.xwayland.enable = true;
    programs.dconf.enable = true;
  };
}
