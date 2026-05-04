{ config, pkgs, lib, ... }:
let
  patchConfig = pkgs.writeShellScript "sabnzbd-patch-config" ''
    CONFIG=/var/lib/sabnzbd/sabnzbd.ini
    HOSTNAME=sabnzbd.nordhammer.it

    if [ ! -f "$CONFIG" ]; then
      printf '[misc]\nhost_whitelist = %s\nport = 8085\n' "$HOSTNAME" > "$CONFIG"
      exit 0
    fi

    ${pkgs.python3}/bin/python3 - <<'EOF'
import configparser, os, sys
config_file = '/var/lib/sabnzbd/sabnzbd.ini'
hostname = 'sabnzbd.nordhammer.it'
c = configparser.RawConfigParser()
c.read(config_file)
if not c.has_section('misc'):
    c.add_section('misc')
wl = c.get('misc', 'host_whitelist', fallback="")
entries = [h.strip() for h in wl.split(',') if h.strip()]
if hostname not in entries:
    entries.append(hostname)
    c.set('misc', 'host_whitelist', ','.join(entries))
    with open(config_file, 'w') as f:
        c.write(f)
EOF
  '';
in
{
  config = lib.mkIf (config.networking.hostName == "FredOS-Mediaserver") {

    users.users.sabnzbd = {
      isSystemUser = true;
      group = "media";
    };

    systemd.tmpfiles.rules = [
      "d /var/lib/sabnzbd 0755 sabnzbd media -"
      "Z /var/lib/sabnzbd 0755 sabnzbd media -"
      "d /mnt/storage/usenet/downloads 2775 sabnzbd media -"
      "Z /mnt/storage/usenet/downloads 2775 sabnzbd media -"
      "d /mnt/storage/usenet/incomplete 2775 sabnzbd media -"
      "Z /mnt/storage/usenet/incomplete 2775 sabnzbd media -"
    ];

    systemd.services.sabnzbd = {
      description = "SABnzbd usenet downloader";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        User = "sabnzbd";
        Group = "media";
        ExecStartPre = patchConfig;
        ExecStart = "${pkgs.sabnzbd}/bin/sabnzbd --config-file /var/lib/sabnzbd/sabnzbd.ini --server 127.0.0.1:8085";
        Restart = "on-failure";
        UMask = "0002";
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = false;
        ReadWritePaths = [
          "/var/lib/sabnzbd"
          "/mnt/storage/usenet"
        ];
        WorkingDirectory = "/var/lib/sabnzbd";
      };
    };
  };
}
