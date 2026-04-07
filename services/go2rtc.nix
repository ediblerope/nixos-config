# services/go2rtc.nix — Native go2rtc camera streaming
# RTSP credentials kept out of the nix store via runtime config templating
{ config, lib, pkgs, ... }:
let
  # Template config with placeholder — real URL injected at runtime
  configTemplate = pkgs.writeText "go2rtc-template.yaml" (builtins.toJSON {
    streams.kids_bedroom = "@RTSP_URL@";
    api.listen = ":1984";
    webrtc.listen = ":8555";
  });

  injectSecrets = pkgs.writeShellScript "go2rtc-inject-secrets" ''
    set -euo pipefail
    SECRETS="/var/secrets/go2rtc-rtsp-url"
    if [ -f "$SECRETS" ]; then
      RTSP_URL=$(tr -d '\n' < "$SECRETS")
      ${pkgs.gnused}/bin/sed "s|@RTSP_URL@|$RTSP_URL|g" ${configTemplate} > /run/go2rtc/config.yaml
    else
      echo "WARNING: $SECRETS not found, camera stream will not work" >&2
      cp ${configTemplate} /run/go2rtc/config.yaml
    fi
  '';
in
{
  config = lib.mkIf (config.networking.hostName == "FredOS-Mediaserver") {

    services.go2rtc = {
      enable = true;
      settings = {
        api.listen = ":1984";
        webrtc.listen = ":8555";
      };
    };

    # Override to use runtime-templated config with secrets
    systemd.services.go2rtc.serviceConfig = {
      RuntimeDirectory = "go2rtc";
      ExecStartPre = [ "!${injectSecrets}" ];
      ExecStart = lib.mkForce "${config.services.go2rtc.package}/bin/go2rtc -config /run/go2rtc/config.yaml";
    };

  };
}
