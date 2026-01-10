# audio.nix
{ config, pkgs, lib, ... }:
{
  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    
    # Enable audio monitoring for game capture
    extraConfig.pipewire."92-low-latency" = {
      context.properties = {
        default.clock.rate = 48000;
        default.clock.quantum = 1024;
        default.clock.min-quantum = 512;
        default.clock.max-quantum = 2048;
      };
    };
  };
  
  # Allow capturing audio from all applications
  environment.etc."pipewire/pipewire.conf.d/99-steam-monitor.conf".text = ''
    context.modules = [
      { name = libpipewire-module-loopback
        args = {
          node.description = "Steam Audio Monitor"
          capture.props = {
            media.class = "Audio/Sink"
            audio.position = [ FL FR ]
          }
          playback.props = {
            media.class = "Audio/Source"
            audio.position = [ FL FR ]
          }
        }
      }
    ]
  '';
}
