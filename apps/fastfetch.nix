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

  # Starship cross-shell prompt
  programs.starship = {
    enable = true;
    settings = {
      "$schema" = "https://starship.rs/config-schema.json";
      format = builtins.concatStringsSep "" [
        "[](fg:#394b70)"
        "$os"
        "[](bg:#e0af68 fg:#394b70)"
        "$hostname"
        "[](bg:#41a6b5 fg:#e0af68)"
        "$directory"
        "[](fg:#41a6b5 bg:#bb9af7)"
        "$git_branch"
        "$git_status"
        "[](fg:#bb9af7)"
        "$nix_shell"
        "\n"
        "$character"
      ];

      os = {
        style = "bg:#394b70 fg:#7dcfff";
        format = "[$symbol ]($style)";
        disabled = false;
        symbols.NixOS = " ";
      };

      hostname = {
        ssh_only = false;
        style = "bg:#e0af68 fg:#1a1b26";
        format = "[ $hostname ]($style)";
      };

      directory = {
        style = "bg:#41a6b5 fg:#1a1b26";
        format = "[ $path ]($style)";
        truncation_length = 4;
        truncation_symbol = ".../";
      };

      git_branch = {
        symbol = "";
        style = "bg:#bb9af7 fg:#1a1b26";
        format = "[ $symbol $branch ]($style)";
      };

      git_status = {
        style = "bg:#bb9af7 fg:#1a1b26";
        format = "[$all_status$ahead_behind ]($style)";
      };

      nix_shell = {
        symbol = " ";
        style = "bold yellow";
        format = " [$symbol$state]($style)";
      };

      character = {
        success_symbol = "[❯](bold purple)";
        error_symbol = "[❯](bold red)";
      };
    };
  };

  # Fish shell settings
  programs.fish.interactiveShellInit = ''
    # Disable default greeting
    set -g fish_greeting
  '';
}
