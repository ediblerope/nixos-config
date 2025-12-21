{ config, pkgs, ... }:
{
  # Install fastfetch, ghostty, and nerd fonts
  environment.systemPackages = with pkgs; [
    fastfetch
  ];
  # Install Nerd Fonts for icon support
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    nerd-fonts.meslo-lg
  ];
  # Create the fastfetch config file with custom image
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
          "text": "echo $(whoami)@$(hostname)  $(uname -r)"
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
    # Powerline-style prompt with background colors
    # Color definitions
    RESET="\[\033[0m\]"
    
    # Powerline separator
    SEP=""
    
    # Background colors with foreground text
    BG_BLUE="\[\033[48;5;33m\]"      # Blue background
    BG_PURPLE="\[\033[48;5;98m\]"    # Purple background
    BG_GREEN="\[\033[48;5;35m\]"     # Green background
    
    # Foreground colors for separators
    FG_BLUE="\[\033[38;5;33m\]"
    FG_PURPLE="\[\033[38;5;98m\]"
    FG_GREEN="\[\033[38;5;35m\]"
    
    # White text
    WHITE="\[\033[97m\]"
    
    # Function to get git branch
    parse_git_branch() {
      local branch=$(git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')
      if [ -n "$branch" ]; then
        echo -e "''${BG_PURPLE}''${FG_GREEN}''${SEP}''${BG_PURPLE}''${WHITE}  $branch ''${RESET}''${FG_PURPLE}''${SEP}"
      else
        echo -e "''${RESET}''${FG_GREEN}''${SEP}"
      fi
    }
    
    # Powerline prompt
    PS1="''${BG_GREEN}''${WHITE} \w ''${RESET}\$(parse_git_branch)''${RESET} "
  '';
  programs.bash.interactiveShellInit = ''
    # Run fastfetch on terminal start
    if [[ $- == *i* ]]; then
      ${pkgs.fastfetch}/bin/fastfetch --config /etc/fastfetch/config.jsonc
    fi
  '';
}
