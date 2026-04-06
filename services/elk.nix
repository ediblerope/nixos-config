{ config, lib, pkgs, ... }:
let
  # Pin all three to the same version — mismatches between ES/Kibana/Filebeat cause errors
  # Check https://www.docker.elastic.co for latest 8.x tag
  elasticVersion = "8.17.0";

  filebeatConfig = pkgs.writeText "filebeat.yml" ''
    filebeat.modules:
      - module: suricata
          eve:
            enabled: true
            var.paths: ["/var/log/suricata/eve.json"]

    # Auto-install Kibana dashboards on first run
    setup.dashboards.enabled: true
    setup.kibana:
      host: "kibana:5601"

    output.elasticsearch:
      hosts: ["elasticsearch:9200"]

    # Reduce logging noise
    logging.level: warning
  '';
in
{
  config = lib.mkIf (config.networking.hostName == "FredOS-Mediaserver") {

    virtualisation.oci-containers.containers = {

      elasticsearch = {
        image = "docker.elastic.co/elasticsearch/elasticsearch:${elasticVersion}";
        environment = {
          # Single-node cluster — no replica shards needed
          "discovery.type" = "single-node";
          # Security disabled — ES is not exposed externally
          "xpack.security.enabled" = "false";
          # Keep heap at 1g; ES default is 50% of RAM which is excessive here
          "ES_JAVA_OPTS" = "-Xms1g -Xmx1g";
        };
        volumes = [ "elasticsearch-data:/usr/share/elasticsearch/data" ];
        extraOptions = [ "--network=elk" ];
      };

      kibana = {
        image = "docker.elastic.co/kibana/kibana:${elasticVersion}";
        environment = {
          "ELASTICSEARCH_HOSTS" = "http://elasticsearch:9200";
          # Cap Node.js heap — default is uncapped
          "NODE_OPTIONS" = "--max-old-space-size=512";
        };
        ports = [ "5601:5601" ];
        extraOptions = [ "--network=elk" ];
        dependsOn = [ "elasticsearch" ];
      };

      filebeat = {
        image = "docker.elastic.co/beats/filebeat:${elasticVersion}";
        extraOptions = [
          "--network=elk"
          # root so it can read /var/log/suricata owned by the suricata user
          "--user=root"
          # Filebeat refuses to start if config file is group/world writable
          "--security-opt=no-new-privileges:true"
        ];
        volumes = [
          "/var/log/suricata:/var/log/suricata:ro"
          "${filebeatConfig}:/usr/share/filebeat/filebeat.yml:ro"
        ];
        dependsOn = [ "elasticsearch" "kibana" ];
      };

    };

    # Create the elk bridge network before any container starts
    systemd.services.init-elk-docker-network = {
      description = "Create elk Docker network";
      after = [ "docker.service" ];
      requires = [ "docker.service" ];
      before = [
        "docker-elasticsearch.service"
        "docker-kibana.service"
        "docker-filebeat.service"
      ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        ${pkgs.docker}/bin/docker network inspect elk >/dev/null 2>&1 \
          || ${pkgs.docker}/bin/docker network create elk
      '';
    };

    # Kibana accessible on the LAN
    networking.firewall.allowedTCPPorts = [ 5601 ];

  };
}
