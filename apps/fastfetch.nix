{ config, pkgs, ... }:

{
  # Install fastfetch and nerd fonts
  environment.systemPackages = with pkgs; [
    fastfetch
  ];

  # Install Nerd Fonts for icon support
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    nerd-fonts.meslo-lg
  ];

  # Create the fastfetch config file with unicode icons
  environment.etc."fastfetch/config.jsonc".text = ''
    {
      "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
      "logo": {
        "source": "auto",
        "padding": {
          "top": 1,
          "left": 2
        }
      },
      "display": {
        "separator": " ",
        "color": {
          "keys": "blue",
          "title": "cyan"
        }
      },
      "modules": [
        {
          "type": "title",
          "format": "{user-name-colored}@{host-name-colored}"
        },
        {
          "type": "separator",
          "string": "─────────────────────────────────"
        },
        {
          "type": "os",
          "key": "❄ ",
          "keyColor": "blue"
        },
        {
          "type": "host",
          "key": "󰌢 ",
          "keyColor": "blue"
        },
        {
          "type": "kernel",
          "key": "󰌽 ",
          "keyColor": "blue"
        },
        {
          "type": "uptime",
          "key": "󰔟 ",
          "keyColor": "blue"
        },
        {
          "type": "packages",
          "key": "󰏖 ",
          "keyColor": "blue"
        },
        {
          "type": "shell",
          "key": "󰆍 ",
          "keyColor": "blue"
        },
        {
          "type": "terminal",
          "key": "󰆍 ",
          "keyColor": "blue"
        },
        {
          "type": "de",
          "key": "󰧨 ",
          "keyColor": "blue"
        },
        {
          "type": "wm",
          "key": "󱂬 ",
          "keyColor": "blue"
        },
        {
          "type": "wmtheme",
          "key": "󰉼 ",
          "keyColor": "blue"
        },
        {
          "type": "icons",
          "key": "󰀻 ",
          "keyColor": "blue"
        },
        {
          "type": "cpu",
          "key": "󰻠 ",
          "keyColor": "green"
        },
        {
          "type": "gpu",
          "key": "󰍛 ",
          "keyColor": "green"
        },
        {
          "type": "memory",
          "key": "󰑭 ",
          "keyColor": "yellow"
        },
        {
          "type": "disk",
          "key": "󰋊 ",
          "keyColor": "yellow"
        },
        {
          "type": "separator",
          "string": "─────────────────────────────────"
        },
        {
          "type": "colors",
          "paddingLeft": 2,
          "symbol": "circle"
        }
      ]
    }
  '';

  # Set up bash with fastfetch and a nice prompt
  programs.bash.promptInit = ''
    # Stylish prompt with icons
    # Color definitions
    RESET="\[\033[0m\]"
    CYAN="\[\033[0;36m\]"
    BLUE="\[\033[0;34m\]"
    PURPLE="\[\033[0;35m\]"
    GREEN="\[\033[0;32m\]"
    YELLOW="\[\033[0;33m\]"
    BCYAN="\[\033[1;36m\]"
    BBLUE="\[\033[1;34m\]"
    BPURPLE="\[\033[1;35m\]"
    BGREEN="\[\033[1;32m\]"
    
    # Function to get git branch
    parse_git_branch() {
      git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
    }
    
    # Set the prompt
    PS1="''${RESET}''${BCYAN}╭─''${RESET} ''${BPURPLE}\u''${RESET}''${CYAN}@''${RESET}''${BBLUE}\h''${RESET} ''${BGREEN} \w''${RESET}''${YELLOW}\$(parse_git_branch)''${RESET}\n''${BCYAN}╰─''${BPURPLE}❯''${RESET} "
  '';

  programs.bash.interactiveShellInit = ''
    # Run fastfetch on terminal start
    if [[ $- == *i* ]]; then
      ${pkgs.fastfetch}/bin/fastfetch --config /etc/fastfetch/config.jsonc
    fi
  '';
}
