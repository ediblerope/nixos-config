# gnome.nix
{ config, pkgs, lib, ... }:

{

# Enable Gnome
# Enable the X11 windowing system.
services.xserver.enable = true;
services.displayManager.gdm.enable = true;
services.desktopManager.gnome.enable = true;

# Apply GNOME settings on login and log
systemd.user.services.gnomeSettings = {
  description = "Apply GNOME custom settings";
  wantedBy = [ "default.target" ];
  after = [
    "graphical-session.target"
    "gnome-session.target"
    "gnome-settings-daemon.service"
  ];
  serviceConfig = {
    Type = "oneshot";
    ExecStart = pkgs.writeShellScript "apply-gnome-settings" ''
      LOG=~/gnome-settings.log
      echo "---- RUN $(date) ----" >> "$LOG"

      export PATH=${pkgs.glib}/bin:$PATH
      export DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/bus"

      # Ensure GNOME is fully ready
      sleep 30
      echo "Running settings..." >> "$LOG"

      # Interface / theme
      gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' >> "$LOG" 2>&1
      gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark' >> "$LOG" 2>&1
      gsettings set org.gnome.desktop.interface accent-color 'purple' >> "$LOG" 2>&1

	  # Media keys
	  gsettings set org.gnome.settings-daemon.plugins.media-keys home "['<Super>e']" >> "$LOG" 2>&1
	  gsettings set org.gnome.settings-daemon.plugins.media-keys control-center "['<Super>i']" >> "$LOG" 2>&1
	
      # Custom keybinding: Super+T → kgx
	  gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/']" >> "$LOG" 2>&1
	  gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ name 'Terminal' >> "$LOG" 2>&1
	  gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ command 'kgx' >> "$LOG" 2>&1
	  gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ binding '<Super>t' >> "$LOG" 2>&1

	  # Mouse acceleration
	  gsettings set org.gnome.desktop.peripherals.mouse accel-profile "flat" >> "$LOG" 2>&1

      echo "DONE" >> "$LOG"
    '';
  };
};

}
