{ config, pkgs, ... }:
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

  # Configure GNOME Console to use Nerd Font
  programs.dconf.profiles.user.databases = [{
    settings = {
      "org/gnome/Console" = {
        use-system-font = false;
        custom-font = "FiraCode Nerd Font 11";
      };
    };
  }];

  # Create a script for the fastfetch command
  environment.etc."fastfetch/custom-info.sh" = {
    text = ''
      #!/bin/sh
      # Color codes
      CYAN="\033[0;36m"
      BLUE="\033[0;34m"
      GREEN="\033[0;32m"
      PURPLE="\033[0;35m"
      GRAY="\033[0;90m"
      RESET="\033[0m"
      
      echo -e "''${CYAN}$(hostname)''${RESET}''${BLUE}@NixOS_Unstable''${RESET} ''${GRAY}-''${RESET} ''${GREEN}$(uname) $(uname -r)''${RESET} ''${GRAY}-''${RESET} ''${PURPLE}$(gnome-shell --version 2>/dev/null | awk '{print $1, $3}')''${RESET}"
    '';
    mode = "0755";
  };

  # Create the fastfetch config file
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
          "type": "command",
          "text": "/etc/fastfetch/custom-info.sh"
        },
        {
          "type": "colors",
          "symbol": "circle"
        }
      ]
    }
  '';

  # Set up bash with fastfetch and a nice prompt
  programs.bash.promptInit = ''
    # Simple colored prompt without backgrounds
    # Foreground colors
    FG_ORANGE="\001$(echo -e '\033[38;5;208m')\002"
    FG_GREEN="\001$(echo -e '\033[38;5;35m')\002"
    FG_CYAN="\001$(echo -e '\033[38;5;37m')\002"
    FG_BLUE="\001$(echo -e '\033[38;5;33m')\002"
    FG_PURPLE="\001$(echo -e '\033[38;5;98m')\002"
    FG_GRAY="\001$(echo -e '\033[38;5;245m')\002"
    RESET="\001$(echo -e '\033[0m')\002"
    
    # Function to build path with colored segments
    build_path_prompt() {
      local output=""
      
      # Username in orange
      output+="''${FG_ORANGE}\u''${RESET} "
      
      # Path segments
      local path="''${PWD/#$HOME/\~}"
      
      # If we're in home directory, just show ~
      if [ "$path" = "~" ]; then
        output+="''${FG_GREEN}~''${RESET}"
        echo -n "$output"
        return
      fi
      
      local IFS='/'
      local parts=($path)
      local colors=("''${FG_GREEN}" "''${FG_CYAN}" "''${FG_BLUE}")
      local i=0
      
      for part in "''${parts[@]}"; do
        if [ -n "$part" ]; then
          local color_idx=$((i % 3))
          if [ $i -gt 0 ]; then
            output+="''${FG_GRAY}/''${RESET}"
          fi
          output+="''${colors[$color_idx]}$part''${RESET}"
          ((i++))
        fi
      done
      
      echo -n "$output"
    }
    
    # Function to get git branch
    parse_git_branch() {
      local branch=$(git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')
      if [ -n "$branch" ]; then
        echo -n " ''${FG_PURPLE} $branch''${RESET}"
      fi
    }
    
    # Set prompt command to rebuild on each prompt
    PROMPT_COMMAND='PS1="$(build_path_prompt)$(parse_git_branch) ''${FG_PURPLE}❯''${RESET} "'
  '';

  programs.bash.interactiveShellInit = ''
    # Run fastfetch on terminal start
    if [[ $- == *i* ]]; then
      ${pkgs.fastfetch}/bin/fastfetch --config /etc/fastfetch/config.jsonc
    fi
  '';
}
