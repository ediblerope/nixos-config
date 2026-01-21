{ config, pkgs, lib, ... }:

let
  sops-nix = builtins.fetchTarball {
    url = "https://github.com/Mic92/sops-nix/archive/master.tar.gz";
  };
in

{
	imports = [
		"${sops-nix}/modules/sops"
	];

	config = lib.mkIf (config.networking.hostName == "FredOS-Mediaserver") {
		
		
		  # Configure sops
  sops = {
    defaultSopsFile = ../secrets/camera.yaml;
    age.keyFile = "/var/lib/sops-nix/key.txt";
    secrets = {
      authelia_session_secret = { };
      authelia_encryption_key = { };
      authelia_jwt_secret = { };
      camera_rtsp_url = { };
      fredrik_password_hash = { };
      kayla_password_hash = { };
    };
  };

  virtualisation.oci-containers = {
    backend = "docker";
    
    containers."go2rtc" = {
      image = "alexxit/go2rtc:latest";
      ports = [ "1984:1984" ];
      volumes = [
        "/var/lib/go2rtc:/config"
      ];
      extraOptions = [
        #"--network=nginx-proxy-manager_default"
      ];
    };
    
    containers."authelia" = {
      image = "authelia/authelia:latest";
      ports = [ "9091:9091" ];
      environment = {
        TZ = "Europe/London";
      };
      volumes = [
        "/var/lib/authelia:/config"
      ];
      extraOptions = [
        #"--network=nginx-proxy-manager_default"
      ];
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/go2rtc 0755 root root -"
    "d /var/lib/authelia 0755 root root -"
  ];

  # Generate go2rtc config with secrets
  systemd.services.go2rtc-config = {
    description = "Generate go2rtc config with secrets";
    wantedBy = [ "docker-go2rtc.service" ];
    before = [ "docker-go2rtc.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      mkdir -p /var/lib/go2rtc
      cat > /var/lib/go2rtc/go2rtc.yaml <<EOF
      streams:
        bedroom_cam:
          - $(cat ${config.sops.secrets.camera_rtsp_url.path})
      
      api:
        listen: ":1984"
      
      webrtc:
        listen: ":8555"
      EOF
    '';
  };

  # Generate Authelia config with secrets
  systemd.services.authelia-config = {
    description = "Generate authelia config with secrets";
    wantedBy = [ "docker-authelia.service" ];
    before = [ "docker-authelia.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      mkdir -p /var/lib/authelia
      cat > /var/lib/authelia/configuration.yml <<EOF
      ---
      theme: light
      server:
        address: 'tcp://0.0.0.0:9091/'
      
      log:
        level: info
      
      authentication_backend:
        file:
          path: /config/users_database.yml
      
      access_control:
        default_policy: deny
        rules:
          - domain: camera.nordhammer.it
            policy: one_factor
      
      session:
        secret: $(cat ${config.sops.secrets.authelia_session_secret.path})
        cookies:
          - domain: nordhammer.it
            authelia_url: https://auth.nordhammer.it
        expiration: 1h
        inactivity: 5m
      
      storage:
        encryption_key: $(cat ${config.sops.secrets.authelia_encryption_key.path})
        local:
          path: /config/db.sqlite3
      
      notifier:
        filesystem:
          filename: /config/notification.txt
      
      identity_validation:
        reset_password:
          jwt_secret: $(cat ${config.sops.secrets.authelia_jwt_secret.path})
      EOF
      
      cat > /var/lib/authelia/users_database.yml <<EOF
      ---
      users:
        fredrik:
          displayname: "Fredrik"
          password: "$(cat ${config.sops.secrets.fredrik_password_hash.path})"
          email: fredrik@nordhammer.it
          groups: []
        kayla:
          displayname: "Kayla"
          password: "$(cat ${config.sops.secrets.kayla_password_hash.path})"
          email: kaylavds@hotmail.co.uk
          groups: []
      EOF
      chmod 600 /var/lib/authelia/users_database.yml
    '';
  };
		
	};
}
