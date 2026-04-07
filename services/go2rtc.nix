# services/go2rtc.nix — Native go2rtc camera streaming
{ config, lib, ... }:
{
  config = lib.mkIf (config.networking.hostName == "FredOS-Mediaserver") {

    services.go2rtc = {
      enable = true;
      settings = {
        # NOTE: RTSP credentials end up in the nix store — same exposure as
        # the old Docker bind-mount config. Acceptable for a local LAN camera.
        streams.kids_bedroom = "rtsp://fredrik:12345678@192.168.4.39:554/stream1";
        api.listen = ":1984";
        webrtc.listen = ":8555";
      };
    };

  };
}
