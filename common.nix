# Common.nix
{ config, pkgs, lib, ... }:

let
  vesktopDark = pkgs.stdenv.mkDerivation {
    pname = "vesktop-dark";
    version = "1.0";

    buildInputs = [ pkgs.makeWrapper ];

    unpackPhase = "true";
    installPhase = ''
      mkdir -p $out/bin
      wrapProgram ${pkgs.vesktop}/bin/vesktop \
        --set GTK_THEME Adwaita:dark \
        --prefix PATH : ${pkgs.coreutils}/bin \
        --prefix PATH : ${pkgs.glib}/bin \
        -o $out/bin/vesktop
    '';
  };
in

{
# Use latest kernel
boot.kernelPackages = pkgs.linuxPackages_latest;

# Shell aliases
environment.shellAliases = {
  update = "sudo nixos-rebuild switch --upgrade --option tarball-ttl 0";
  clean = "sudo nix-collect-garbage -d";  # Clean old generations
  ll = "ls -alh";
};

# Add packages
environment.systemPackages = with pkgs; [
	git
	gnomeExtensions.blur-my-shell
	gnomeExtensions.just-perfection
	gnomeExtensions.appindicator
	gnomeExtensions.hot-edge
];
 
# GNOME + Keybinds
# Enable the X11 windowing system.
services.xserver.enable = true;
services.displayManager.gdm.enable = true;
services.desktopManager.gnome.enable = true;

# Apply GNOME settings on login
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

      echo "DONE" >> "$LOG"
    '';
  };
};


# Define a user account. Don't forget to set a password with ‘passwd’.
users.users.fred = {
  isNormalUser = true;
  description = "fred";
  extraGroups = [ "networkmanager" "wheel" ];
  packages = with pkgs; [
    bazaar
    fastfetch
    vesktopDark
  ];
};

# Allow unfree packages
nixpkgs.config.allowUnfree = true;
 
# Services
services.flatpak.enable = true;

######################
##BORING STUFF BELOW##
######################
# Enable networking
networking.networkmanager.enable = true;
 
# Set your time zone.
time.timeZone = "Europe/London";
 
# Select internationalisation properties.
i18n.defaultLocale = "en_GB.UTF-8";
i18n.extraLocaleSettings = {
	LC_ADDRESS = "en_GB.UTF-8";
	LC_IDENTIFICATION = "en_GB.UTF-8";
	LC_MEASUREMENT = "en_GB.UTF-8";
	LC_MONETARY = "en_GB.UTF-8";
	LC_NAME = "en_GB.UTF-8";
	LC_NUMERIC = "en_GB.UTF-8";
	LC_PAPER = "en_GB.UTF-8";
	LC_TELEPHONE = "en_GB.UTF-8";
	LC_TIME = "en_GB.UTF-8";
};

# Enable sound with pipewire.
services.pulseaudio.enable = false;
security.rtkit.enable = true;
services.pipewire = {
	enable = true;
	alsa.enable = true;
	alsa.support32Bit = true;
	pulse.enable = true;
};

# Configure keymap in X11
services.xserver.xkb = {
	layout = "gb";
	variant = "";
};
 
# Configure console keymap
console.keyMap = "uk";

}
