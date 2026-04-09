# audio.nix
{ config, pkgs, lib, ... }:
{
  config = lib.mkIf (lib.elem config.networking.hostName [ "FredOS-Gaming" "FredOS-Macbook" ]) {
    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;

      extraConfig."pipewire-pulse"."10-quirk-rules" = {
        "pulse.rules" = [
          {
            matches = [ { "application.name" = "~Chromium.*"; } ];
            actions = { quirks = [ "block-source-volume" ]; };
          }
          {
            matches = [ { "application.name" = "~Electron.*"; } ];
            actions = { quirks = [ "block-source-volume" ]; };
          }
          {
            matches = [ { "application.name" = "~vesktop.*"; } ];
            actions = { quirks = [ "block-source-volume" ]; };
          }
        ];
      };
    };
  };
}
