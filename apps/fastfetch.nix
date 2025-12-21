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
    # Powerline separator
    SEP=""
    
    # Background colors
    BG_BLUE="$(echo -e '\033[48;5;33m')"
    BG_PURPLE="$(echo -e '\033[48;5;98m')"
    BG_GREEN="$(echo -e '\033[48;5;35m')"
    BG_CYAN="$(echo -e '\033[48;5;37m')"
    
    # Foreground colors for separators
    FG_BLUE="$(echo -e '\033[38;5;33m')"
    FG_PURPLE="$(echo -e '\033[38;5;98m')"
    FG_GREEN="$(echo -e '\033[38;5;35m')"
    FG_CYAN="$(echo -e '\033[38;5;37m')"
    
    # White text and reset
    WHITE="$(echo -e '\033[97m')"
    RESET="$(echo -e '\033[0m')"
    
    # Function to build path with colored segments
    build_path_prompt() {
      local path="''${PWD/#$HOME/~}"
      local IFS='/'
      local parts=($path)
      local output=""
      local colors=("''${BG_GREEN}" "''${BG_CYAN}" "''${BG_BLUE}")
      local fg_colors=("''${FG_GREEN}" "''${FG_CYAN}" "''${FG_BLUE}")
      local i=0
      
      for part in "''${parts[@]}"; do
        local color_idx=$((i % 3))
        local next_color_idx=$(((i + 1) % 3))
        
        if [ -n "$part" ]; then
          output+="''${colors[$color_idx]}''${WHITE} $part "
          if [ $i -lt $((''${#parts[@]} - 1)) ]; then
            output+="''${colors[$next_color_idx]}''${fg_colors[$color_idx]}''${SEP}"
          fi
          ((i++))
        fi
      done
      
      echo -n "$output"
    }
    
    # Function to get git branch
    parse_git_branch() {
      local branch=$(git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')
      if [ -n "$branch" ]; then
        echo -n "''${BG_PURPLE}''${FG_CYAN}''${SEP}''${BG_PURPLE}''${WHITE}  $branch ''${RESET}''${FG_PURPLE}''${SEP}"
      else
        echo -n "''${RESET}''${FG_BLUE}''${SEP}"
      fi
    }
    
    # Set prompt command to rebuild on each prompt
    PROMPT_COMMAND='PS1="$(build_path_prompt)$(parse_git_branch)''${RESET} "'
  '';
  programs.bash.interactiveShellInit = ''
    # Run fastfetch on terminal start
    if [[ $- == *i* ]]; then
      ${pkgs.fastfetch}/bin/fastfetch --config /etc/fastfetch/config.jsonc
    fi
  '';
}
