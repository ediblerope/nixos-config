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
  };

  environment.etc."pipewire/pipewire-pulse.d/10-quirk-rules.conf".text = ''
    pulse.rules = [
      {
        matches = [ { application.name = "~Chromium.*" } ]
        actions = { quirks = [ block-source-volume ] }
      }
    ]
  '';
}
