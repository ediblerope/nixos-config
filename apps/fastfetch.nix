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

  # Download your custom image from GitHub
  environment.etc."fastfetch/logo.png".source = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/ediblerope/nixos-config/main/walls/owventures.png";
    sha256 = "0000000000000000000000000000000000000000000000000000";
  };

  # Create the fastfetch config file with custom image
  environment.etc."fastfetch/config.jsonc".text = ''
    {
      "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
      "logo": {
        "source": "/etc/fastfetch/logo.png",
        "type": "kitty-direct",
        "width": 30,
        "height": 15,
        "padding": {
          "top": 1,
          "left": 2,
          "right": 4
        }
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
          "format": "{user-name-colored}@{host-name-colored}"
        },
        {
          "type": "separator",
          "string": "─────────────────────────────────"
        },
        {
          "type": "os",
          "keyColor": "blue"
        },
        {
          "type": "host",
          "keyColor": "blue"
        },
        {
          "type": "kernel",
          "keyColor": "blue"
        },
        {
          "type": "uptime",
          "keyColor": "blue"
        },
        {
          "type": "packages",
          "keyColor": "blue"
        },
        {
          "type": "shell",
          "keyColor": "blue"
        },
        {
          "type": "terminal",
          "keyColor": "blue"
        },
        {
          "type": "de",
          "keyColor": "blue"
        },
        {
          "type": "wm",
          "keyColor": "blue"
        },
        {
          "type": "wmtheme",
          "keyColor": "blue"
        },
        {
          "type": "icons",
          "keyColor": "blue"
        },
        {
          "type": "cpu",
          "keyColor": "green"
        },
        {
          "type": "gpu",
          "keyColor": "green"
        },
        {
          "type": "memory",
          "keyColor": "yellow"
        },
        {
          "type": "disk",
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
