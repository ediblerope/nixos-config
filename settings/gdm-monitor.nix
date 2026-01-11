# settings/gdm-monitor-sync.nix
{ config, pkgs, lib, ... }:

{
  # Copy monitors.xml to GDM's config directory to prevent display mode changes during login
  # This eliminates the black screen/signal loss when transitioning from GDM to user session
  
  environment.etc."gdm-monitors.xml" = {
    source = pkgs.writeText "monitors.xml" ''
      <monitors version="2">
        <configuration>
          <layoutmode>physical</layoutmode>
          <logicalmonitor>
            <x>0</x>
            <y>0</y>
            <scale>1</scale>
            <primary>yes</primary>
            <monitor>
              <monitorspec>
                <connector>DP-3</connector>
                <vendor>GBT</vendor>
                <product>G34WQCP</product>
                <serial>25272B000088</serial>
              </monitorspec>
              <mode>
                <width>3440</width>
                <height>1440</height>
                <rate>190.000</rate>
              </mode>
            </monitor>
          </logicalmonitor>
        </configuration>
      </monitors>
    '';
    target = "gdm-monitors.xml";
  };

  # Create GDM config directory and symlink the monitors.xml file
  systemd.tmpfiles.rules = [
    "d /var/lib/gdm/.config 0711 gdm gdm"
    "L+ /var/lib/gdm/.config/monitors.xml - - - - /etc/gdm-monitors.xml"
  ];
}
