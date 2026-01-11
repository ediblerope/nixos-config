# settings/gdm-monitor-sync.nix
{ config, pkgs, lib, ... }:
{
  # Copy monitors.xml to GDM's config directory to prevent display mode changes during login
  # This eliminates the black screen/signal loss when transitioning from GDM to user session
  config = lib.mkIf (config.networking.hostName == "FredOS-Gaming") {  
    # Copy monitors.xml to GDM's config directory
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
    
    systemd.tmpfiles.rules = [
      "d /var/lib/gdm/.config 0711 gdm gdm"
      "L+ /var/lib/gdm/.config/monitors.xml - - - - /etc/gdm-monitors.xml"
    ];
    
    # Log what GDM is actually using
    systemd.services.gdm-display-check = {
      description = "Log GDM display settings";
      wantedBy = [ "gdm.service" ];
      after = [ "gdm.service" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.writeShellScript "check-gdm-display" ''
          sleep 5
          DISPLAY=:1024 ${pkgs.xorg.xrandr}/bin/xrandr > /tmp/gdm-display-info.txt 2>&1 || true
          echo "=== GDM monitors.xml ===" >> /tmp/gdm-display-info.txt
          cat /var/lib/gdm/.config/monitors.xml >> /tmp/gdm-display-info.txt 2>&1 || true
        ''}";
      };
    };
  }; # <-- This was missing
}
