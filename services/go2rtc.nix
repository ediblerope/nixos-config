{ config, pkgs, lib, ... }:

{
  config = lib.mkIf (config.networking.hostName == "FredOS-Mediaserver") {

    virtualisation.oci-containers = {
      backend = "docker";

      # --- Authelia ---
      #containers."authelia" = {
      #  image = "authelia/authelia:latest";
      #  volumes = [
      #    "/home/fred/docker/authelia/config.yml:/config/configuration.yml:ro"
      #    "/home/fred/docker/authelia/users_database.yml:/config/users_database.yml:ro"
      #    "/home/fred/docker/authelia/secrets:/secrets:ro"
      #  ];
      #  ports = [ "9091:9091" ];
      #  extraOptions = [ "--restart" "unless-stopped" ];
      #};

      # --- Go2RTC ---
      containers."go2rtc" = {
        image = "blakeblackshear/go2rtc:latest";
        volumes = [
          "/home/fred/docker/go2rtc/config.yml:/config/config.yml:ro"
        ];
        ports = [ "1984:1984" ];
        extraOptions = [ "--restart" "unless-stopped" ];
      };
    };

    # --- Create directories ---
    systemd.tmpfiles.rules = [
      # Local secrets & configs
      "d /home/fred/docker/authelia/secrets 0700 fred users -"
      "d /home/fred/docker/go2rtc 0755 fred users -"
    ];
  };
}
