{ config, lib, pkgs, ... }:

let
  # Acquisition config is written to the host config dir before the container
  # starts, so it persists across container restarts and reflects Nix config.
  acquisYaml = ''
    - source: journalctl
      journalctl_filter:
        - "-u"
        - "sshd"
      labels:
        type: syslog
  '';

  # Generates /run/crowdsec-bouncer/config.yaml at service start, injecting the
  # API key from /var/lib/secrets/crowdsec-bouncer-key without it ever entering
  # the Nix store. See services/crowdsec.md for key setup instructions.
  bouncerPreStart = pkgs.writeShellScript "crowdsec-bouncer-prestart" ''
    set -euo pipefail

    KEY_FILE=/var/lib/secrets/crowdsec-bouncer-key
    if [ ! -f "$KEY_FILE" ]; then
      echo "ERROR: $KEY_FILE not found. See services/crowdsec.md for setup steps." >&2
      exit 1
    fi

    API_KEY=$(cat "$KEY_FILE")

    cat > /run/crowdsec-bouncer/config.yaml << EOF
    mode: nftables
    pid_dir: /run/crowdsec-bouncer/
    update_frequency: 10s
    log_mode: stdout
    log_level: info
    api_url: http://127.0.0.1:8080
    api_key: $API_KEY
    disable_ipv6: false
    deny_action: DROP
    deny_log: false
    nftables:
      ipv4:
        enabled: true
        set-only: false
        table: crowdsec
        chain: crowdsec-chain
      ipv6:
        enabled: true
        set-only: false
        table: crowdsec6
        chain: crowdsec-chain6
    EOF
  '';
in
{
  config = lib.mkIf (config.networking.hostName == "FredOS-Mediaserver") {

    virtualisation.docker.enable = true;
    virtualisation.oci-containers.backend = "docker";

    # CrowdSec LAPI runs as a Docker container.
    # Collections are installed on first boot via the COLLECTIONS env var.
    # Journals are mounted read-only so CrowdSec can run journalctl inside the container.
    virtualisation.oci-containers.containers.crowdsec = {
      image = "crowdsecurity/crowdsec:latest";
      ports = [ "127.0.0.1:8080:8080" ];
      volumes = [
        "/var/lib/crowdsec/data:/var/lib/crowdsec/data"
        "/var/lib/crowdsec/config:/etc/crowdsec"
        "/var/log/journal:/var/log/journal:ro"
        "/run/log/journal:/run/log/journal:ro"
        "/etc/machine-id:/etc/machine-id:ro"
      ];
      environment = {
        COLLECTIONS = "crowdsecurity/linux crowdsecurity/sshd";
      };
    };

    # Write acquisition config into the host config dir before the container starts.
    systemd.services.docker-crowdsec.preStart = ''
      mkdir -p /var/lib/crowdsec/config/acquis.d
      cat > /var/lib/crowdsec/config/acquis.d/nixos.yaml << 'ACQUIS'
      ${acquisYaml}
      ACQUIS
    '';

    systemd.tmpfiles.rules = [
      "d /var/lib/crowdsec/data   0750 root root -"
      "d /var/lib/crowdsec/config 0750 root root -"
      "d /var/lib/secrets         0700 root root -"
    ];

    # Firewall bouncer runs natively. API key is injected at start time from
    # /var/lib/secrets/crowdsec-bouncer-key — see services/crowdsec.md.
    systemd.services.crowdsec-firewall-bouncer = {
      description = "CrowdSec nftables firewall bouncer";
      after = [ "network.target" "docker-crowdsec.service" ];
      wants = [ "docker-crowdsec.service" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        RuntimeDirectory = "crowdsec-bouncer";
        ExecStartPre = bouncerPreStart;
        ExecStart = "${pkgs.crowdsec-firewall-bouncer}/bin/cs-firewall-bouncer -c /run/crowdsec-bouncer/config.yaml";
        Restart = "on-failure";
        RestartSec = "5s";
        AmbientCapabilities = [ "CAP_NET_ADMIN" "CAP_NET_RAW" ];
        CapabilityBoundingSet = [ "CAP_NET_ADMIN" "CAP_NET_RAW" ];
      };
    };
  };
}
