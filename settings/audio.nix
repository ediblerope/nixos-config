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

      wireplumber.extraConfig."10-mic-boost" = {
        "monitor.alsa.rules" = [{
          matches = [{ "node.name" = "~alsa_input.*"; }];
          actions.update-props."audio.volume" = 2.0;
        }];
      };

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
