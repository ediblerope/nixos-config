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
          "type": "custom",
          "format": "{#blue}{user-name}{#reset}{#cyan}@{#reset}{#blue}{host-name}{#reset} {#green}{kernel}{#reset}"
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
