{ config, pkgs, lib, ... }:
{
  config = lib.mkIf (config.networking.hostName == "FredOS-Mediaserver") {
    virtualisation.docker.enable = true;

    systemd.tmpfiles.rules = [
      "d /var/lib/7dtd             0755 root root -"
      "d /var/lib/7dtd/saves       0755 root root -"
      "d /var/lib/7dtd/serverfiles 0755 root root -"
      "d /var/lib/7dtd/lgsm        0755 root root -"
      "d /var/lib/7dtd/log         0755 root root -"
      "d /var/lib/7dtd/backups     0755 root root -"
    ];

    ## <----- 7 DAYS TO DIE ----> ##
    virtualisation.oci-containers = {
      backend = "docker";
      containers."7dtd" = {
        image = "vinanrra/7dtd-server:latest";
        volumes = [
          "/var/lib/7dtd/saves:/home/sdtdserver/.local/share/7DaysToDie"
          "/var/lib/7dtd/serverfiles:/home/sdtdserver/serverfiles"
          "/var/lib/7dtd/lgsm:/home/sdtdserver/lgsm/config-lgsm/sdtdserver"
          "/var/lib/7dtd/log:/home/sdtdserver/log"
          "/var/lib/7dtd/backups:/home/sdtdserver/lgsm/backup"
        ];
        ports = [
          "26900:26900/tcp"
          "26900:26900/udp"
          "26901:26901/udp"
          "26902:26902/udp"
          # WebDashboard — localhost-only; nginx reverse-proxies it with Authelia
          "127.0.0.1:8090:8080/tcp"
        ];
        environment = {
          START_MODE = "1";
          VERSION    = "stable";
          TimeZone   = "Europe/Stockholm";
          TEST_ALERT = "NO";
        };
      };
    };

    systemd.services."7dtd-configure" = {
      description = "Patch 7DTD sdtdserver.xml on first install";
      after = [ "docker-7dtd.service" ];
      wants = [ "docker-7dtd.service" ];
      wantedBy = [ "multi-user.target" ];
      path = with pkgs; [ gnused coreutils systemd ];
      script = ''
        MARKER=/var/lib/7dtd/.configured
        CONFIG=/var/lib/7dtd/serverfiles/sdtdserver.xml
        if [ -f "$MARKER" ]; then
          echo "Already configured; skipping."
          exit 0
        fi
        echo "Waiting for $CONFIG (install can take 15+ minutes on first boot)..."
        for i in $(seq 1 180); do
          [ -f "$CONFIG" ] && break
          sleep 10
        done
        if [ ! -f "$CONFIG" ]; then
          echo "Timed out waiting for $CONFIG; will retry next boot."
          exit 1
        fi

        set_prop() {
          sed -i "s|<property name=\"$1\"[^/]*value=\"[^\"]*\"|<property name=\"$1\" value=\"$2\"|" "$CONFIG"
        }

        set_prop ServerName          "Nordhammer.it"
        set_prop ServerPassword      "DaveSmells"
        set_prop GameWorld           "RWG"
        set_prop WorldGenSeed        "Nordhammer"
        set_prop WorldGenSize        "8192"
        set_prop GameName            "Nordhammer"
        set_prop WebDashboardEnabled "true"

        touch "$MARKER"
        echo "Patched; restarting container to apply."
        systemctl restart docker-7dtd.service
      '';
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
    };

    networking.firewall.allowedTCPPorts = [ 26900 ];
    networking.firewall.allowedUDPPorts = [ 26900 26901 26902 ];
  };
}
