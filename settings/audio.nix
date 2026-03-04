# audio.nix
{ config, pkgs, lib, ... }:
{
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;

    extraConfig.pulse."10-quirk-rules" = {
      "pulse.rules" = [
        {
          matches = [ { "application.name" = "~Chromium.*"; } ];
          actions = { quirks = [ "block-source-volume" ]; };
        }
      ];
    };
  };
}
