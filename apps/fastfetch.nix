{ config, pkgs, lib, ... }:
{
  # Install fastfetch
  environment.systemPackages = with pkgs; [
    fastfetch
  ];

  # Install Nerd Fonts for icon support
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    nerd-fonts.meslo-lg
  ];

  # Simple fastfetch config — shown on terminal start
  # Run `fastfetch` manually for full system info
  environment.etc."fastfetch/config.jsonc".text = ''
    {
      "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
      "logo": {
        "source": "none"
      },
      "display": {
        "separator": " ",
        "color": {
          "keys": "blue",
          "title": "cyan"
        },
        "key": {
          "type": "icon"
        }
      },
      "modules": [
        {
          "type": "title",
          "format": "{user-name}@{host-name}"
        },
        "separator",
        "os",
        "kernel",
        "shell",
        "terminal",
        "uptime",
        "memory"
      ]
    }
  '';

  # Fish prompt and terminal startup
  programs.fish.interactiveShellInit = ''
    # Run fastfetch on terminal start
    fastfetch --config /etc/fastfetch/config.jsonc

    # Custom prompt
    function fish_prompt
      set -l last_status $status

      # Nix-shell indicator
      if set -q IN_NIX_SHELL
        set_color yellow
        printf '[nix-shell] '
        set_color normal
      end

      # Line 1:  username ~ hostname
      set_color green
      printf ' '
      set_color yellow
      printf '%s' $USER
      set_color normal
      printf ' '

      # Path with colored segments
      set -l gitdir (command git rev-parse --show-toplevel 2>/dev/null)
      set -l realhome (string escape --style=regex -- $HOME)
      set -l path (string replace -r "^$realhome" '~' $PWD)
      set -l parts (string split '/' $path)
      set -l colors green cyan blue

      for i in (seq (count $parts))
        set -l part $parts[$i]
        if test -n "$part"
          if test $i -gt 1
            set_color brblack
            printf '/'
          end
          set -l cidx (math '(' $i - 1 ')' '%' 3 + 1)
          set_color $colors[$cidx]
          printf '%s' $part
        end
      end

      # Hostname
      set_color brblack
      printf ' '
      set_color magenta
      printf '%s' (hostname)
      set_color normal
      printf '\n'

      # Line 2: ❯
      if test $last_status -ne 0
        set_color red
      else
        set_color magenta
      end
      printf '❯ '
      set_color normal
    end

    # Disable the default right prompt
    function fish_right_prompt; end
  '';
}
