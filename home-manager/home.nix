# settings/home.nix
{ config, pkgs, ... }:

{
  # Define the state version for Home Manager
  home.stateVersion = "25.11"; # Use your current NixOS version or a recent one

  # --- Packages for the user ---
  # These are packages installed for the user only, not system-wide.
  home.packages = with pkgs; [
    #
  ];

  # --- GNOME/dconf Settings via Home Manager ---
  # This section replaces the troublesome 'systemd.user.services.gnomeSettings' script!
  dconf.settings = {
    # Interface / theme (Example from your script)
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      gtk-theme = "Adwaita-dark";
      # accent-color is not directly exposed via dconf in this way
    };

    # Custom keybindings (Example from your script)
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

    # Mouse acceleration (Example from your script)
    "org/gnome/desktop/peripherals/mouse" = {
      accel-profile = "flat";
    };

    # You can add many more settings here, like wallpaper, etc.
  };

  # --- Aliases (Moved from system-wide common.nix) ---
  # These aliases are now defined for the user's shell (e.g., bash/zsh).
  programs.bash.enable = true; # Or programs.zsh.enable = true;
  programs.bash.shellAliases = {
    clean = "sudo nix-collect-garbage -d"; # Still needs sudo for system collection
    ll = "ls -alh";
  };
}
