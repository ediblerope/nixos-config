{ config, pkgs, lib, ... }:
let
  patchConfig = pkgs.writeShellScript "sabnzbd-patch-config" ''
    CONFIG=/var/lib/sabnzbd/sabnzbd.ini
    HOSTNAME=sabnzbd.nordhammer.it

    if [ ! -f "$CONFIG" ]; then
      printf '[misc]\nhost_whitelist = %s\nport = 8085\n' "$HOSTNAME" > "$CONFIG"
      exit 0
    fi

    if ${pkgs.gnugrep}/bin/grep -q "^host_whitelist" "$CONFIG"; then
      ${pkgs.gnused}/bin/sed -i "s/^host_whitelist =.*/host_whitelist = $HOSTNAME/" "$CONFIG"
    else
      ${pkgs.gnused}/bin/sed -i "/^\[misc\]/a host_whitelist = $HOSTNAME" "$CONFIG"
    fi
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
