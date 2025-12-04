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
dconf.settings = {
  # Interface / theme
  "org/gnome/desktop/interface" = {
    color-scheme = "prefer-dark";
    gtk-theme = "Adwaita-dark";
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

  # --- Aliases (Moved from system-wide common.nix) ---
  # These aliases are now defined for the user's shell (e.g., bash/zsh).
  programs.bash.enable = true; # Or programs.zsh.enable = true;
  programs.bash.shellAliases = {
    clean = "sudo nix-collect-garbage -d"; # Still needs sudo for system collection
    ll = "ls -alh";
  };
}
