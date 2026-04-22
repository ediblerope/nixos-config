# services/authelia.nix — Native Authelia SSO with auto-migration from Docker
{ config, lib, pkgs, ... }:
let
  # Migrates secrets + user DB from the old Docker Authelia setup
  setupScript = pkgs.writeShellScript "authelia-setup" ''
    set -euo pipefail
    YQ="${pkgs.yq-go}/bin/yq"
    DOCKER_CONFIG="/home/fred/docker/authelia/configuration.yml"
    SECRETS_DIR="/var/secrets/authelia"
    STATE_DIR="/var/lib/authelia-main"

    mkdir -p "$SECRETS_DIR"
    mkdir -p "$STATE_DIR"

    # Migrate secrets from Docker config if they haven't been extracted yet
    if [ -f "$DOCKER_CONFIG" ]; then
      if [ ! -f "$SECRETS_DIR/jwt_secret" ]; then
        $YQ '.identity_validation.reset_password.jwt_secret' "$DOCKER_CONFIG" \
          | tr -d '"' > "$SECRETS_DIR/jwt_secret"
        echo "Migrated jwt_secret"
      fi
      if [ ! -f "$SECRETS_DIR/session_secret" ]; then
        $YQ '.session.secret' "$DOCKER_CONFIG" \
          | tr -d '"' > "$SECRETS_DIR/session_secret"
        echo "Migrated session_secret"
      fi
      if [ ! -f "$SECRETS_DIR/storage_encryption_key" ]; then
        $YQ '.storage.encryption_key' "$DOCKER_CONFIG" \
          | tr -d '"' > "$SECRETS_DIR/storage_encryption_key"
        echo "Migrated storage_encryption_key"
      fi
    fi

    chmod 644 "$SECRETS_DIR"/*

    # Migrate users database
    if [ ! -f "$STATE_DIR/users_database.yml" ] && \
       [ -f "/home/fred/docker/authelia/users_database.yml" ]; then
      cp /home/fred/docker/authelia/users_database.yml "$STATE_DIR/"
      chown authelia-main:authelia-main "$STATE_DIR/users_database.yml"
      echo "Migrated users_database.yml"
    fi

    echo "Authelia setup complete."
  '';
in
{
  config = lib.mkIf (config.networking.hostName == "FredOS-Mediaserver") {

    services.authelia.instances.main = {
      enable = true;

      secrets = {
        jwtSecretFile = "/var/secrets/authelia/jwt_secret";
        storageEncryptionKeyFile = "/var/secrets/authelia/storage_encryption_key";
        sessionSecretFile = "/var/secrets/authelia/session_secret";
      };

      settings = {
        theme = "dark";
        server.address = "tcp://127.0.0.1:9091/";

        log = {
          level = "info";
          format = "text";
        };

        authentication_backend.file.path = "/var/lib/authelia-main/users_database.yml";

        access_control = {
          default_policy = "deny";
          rules = [
            { domain = "camera.nordhammer.it";   policy = "one_factor"; }
            { domain = "homepage.nordhammer.it"; policy = "one_factor"; }
            { domain = "7dtd.nordhammer.it";     policy = "one_factor"; }
            { domain = "adguard.nordhammer.it";  policy = "one_factor"; }
          ];
        };

        session = {
          cookies = [{
            domain = "nordhammer.it";
            authelia_url = "https://auth.nordhammer.it";
          }];
          expiration = "1h";
          inactivity = "5m";
        };

        storage.local.path = "/var/lib/authelia-main/db.sqlite3";
        notifier.filesystem.filename = "/var/lib/authelia-main/notification.txt";
      };
    };

    # Auto-migrate Docker Authelia data on first deploy
    systemd.services.authelia-setup = {
      description = "Migrate Authelia secrets and user database from Docker";
      before = [ "authelia-main.service" ];
      requiredBy = [ "authelia-main.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = setupScript;
      };
    };
  };
}
