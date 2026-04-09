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

  # Simple fastfetch config — run `fastfetch` manually for system info
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

  # Fish shell settings and custom powerline prompt
  programs.fish.interactiveShellInit = ''
    # Disable default greeting
    set -g fish_greeting

    # Custom powerline prompt
    function fish_prompt
      set -l last_status $status

      # Nix-shell indicator
      if set -q IN_NIX_SHELL
        set_color -o yellow
        printf "[nix-shell] "
        set_color normal
      end

      # --- Line 1: powerline segments ---
      # Left round cap + NixOS icon
      set_color 394b70
      printf ""
      set_color 7dcfff -b 394b70
      printf " "

      # Arrow transition: nix -> hostname
      set_color 394b70 -b e0af68
      printf ""
      set_color 000000 -b e0af68
      printf " %s " (hostname)

      # Path segments - each folder gets its own color
      set -l realhome (string escape --style=regex -- $HOME)
      set -l rawpath (string replace -r "^$realhome" "~" $PWD)
      set -l parts (string split "/" $rawpath)
      set -l path_colors 41a6b5 9ece6a 7aa2f7

      set -l prev_bg e0af68
      set -l seg_count 0

      for part in $parts
        if test -n "$part"
          set seg_count (math $seg_count + 1)
          set -l cidx (math "(" $seg_count - 1 ")" "%" 3 + 1)
          set -l seg_bg $path_colors[$cidx]

          # Arrow from previous segment
          set_color $prev_bg -b $seg_bg
          printf ""
          set_color 1a1b26 -b $seg_bg
          printf " %s " $part

          set prev_bg $seg_bg
        end
      end

      # Git branch (if in a repo)
      set -l branch (command git branch --show-current 2>/dev/null)
      if test -n "$branch"
        set_color $prev_bg -b bb9af7
        printf ""
        set_color 1a1b26 -b bb9af7
        printf "  %s " $branch
        set prev_bg bb9af7
      end

      # Final arrow to terminal bg
      set_color $prev_bg -b normal
      printf ""
      set_color normal
      printf "\n"

      # --- Line 2: prompt character ---
      if test $last_status -ne 0
        set_color red
      else
        set_color magenta
      end
      printf "❯ "
      set_color normal
    end

    function fish_right_prompt; end
  '';
}
