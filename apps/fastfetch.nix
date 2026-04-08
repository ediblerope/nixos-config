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
    # Disable default greeting
    set -g fish_greeting

    # Custom prompt
    function fish_prompt
      set -l last_status $status

      # Nix-shell indicator
      if set -q IN_NIX_SHELL
        set_color -b yellow black
        printf ' nix-shell '
        set_color normal
        printf ' '
      end

      # Line 1:  hostname ~/path
      set_color -b green black
      printf '  '
      set_color -b yellow black
      printf ' %s ' (hostname)
      set_color -b blue white
      # Path with colored segments
      set -l realhome (string escape --style=regex -- $HOME)
      set -l path (string replace -r "^$realhome" '~' $PWD)
      printf ' %s ' $path
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
