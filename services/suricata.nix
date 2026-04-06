{ config, lib, pkgs, ... }:
{
  config = lib.mkIf (config.networking.hostName == "FredOS-Mediaserver") {

    services.suricata = {
      enable = true;

      # Default disabledRules covers DNP3 (2270000-2270004); add Modbus rules
      # which also fail to parse because those protocols are disabled in the build
      disabledRules = [
        "2270000" "2270001" "2270002" "2270003" "2270004"
        "2250005" "2250006" "2250007" "2250008" "2250009"
      ];

      settings = {
        vars.address-groups = {
          # Your local networks — Suricata won't alert on traffic within these
          HOME_NET = "[192.168.0.0/16,10.0.0.0/8,172.16.0.0/12,127.0.0.0/8]";
          EXTERNAL_NET = "!$HOME_NET";
        };

        # IDS mode: passive monitoring (read-only, no blocking)
        # To enable IPS later, swap this for nfqueue mode
        af-packet = [
          { interface = "eno1"; }
        ];

        # Structured JSON log — useful for dashboards and log aggregation
        outputs = [
          {
            eve-log = {
              enabled = true;
              filetype = "regular";
              filename = "eve.json";
              community-id = true;
              types = [
                { alert = { tagged-packets = "yes"; }; }
                { anomaly = {}; }
                { drop = {}; }
              ];
            };
          }
          # Human-readable alert log for quick inspection
          {
            fast = {
              enabled = true;
              filename = "fast.log";
              append = "yes";
            };
          }
        ];

        # Enable unix socket so suricatasc can query running state
        unix-command.enabled = true;

        classification-file = "${pkgs.suricata}/etc/suricata/classification.config";
        reference-config-file = "${pkgs.suricata}/etc/suricata/reference.config";
      };
    };

    # Make suricata CLI tools available (suricatasc, suricata-update)
    environment.systemPackages = [ pkgs.suricata ];

  };
}
