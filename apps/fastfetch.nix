{ config, pkgs, ... }:

{
  # Install fastfetch
  environment.systemPackages = with pkgs; [
    fastfetch
  ];

  # Create the fastfetch config file
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
        "separator": " → ",
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
          "key": "OS",
          "keyColor": "blue"
        },
        {
          "type": "host",
          "key": "Host",
          "keyColor": "blue"
        },
        {
          "type": "kernel",
          "key": "Kernel",
          "keyColor": "blue"
        },
        {
          "type": "uptime",
          "key": "Uptime",
          "keyColor": "blue"
        },
        {
          "type": "packages",
          "key": "Packages",
          "keyColor": "blue"
        },
        {
          "type": "shell",
          "key": "Shell",
          "keyColor": "blue"
        },
        {
          "type": "terminal",
          "key": "Terminal",
          "keyColor": "blue"
        },
        {
          "type": "de",
          "key": "DE",
          "keyColor": "blue"
        },
        {
          "type": "wm",
          "key": "WM",
          "keyColor": "blue"
        },
        {
          "type": "wmtheme",
          "key": "Theme",
          "keyColor": "blue"
        },
        {
          "type": "icons",
          "key": "Icons",
          "keyColor": "blue"
        },
        {
          "type": "cpu",
          "key": "CPU",
          "keyColor": "green"
        },
        {
          "type": "gpu",
          "key": "GPU",
          "keyColor": "green"
        },
        {
          "type": "memory",
          "key": "Memory",
          "keyColor": "yellow"
        },
        {
          "type": "disk",
          "key": "Disk",
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

  # Set up bash to run fastfetch on start
  programs.bash.interactiveShellInit = ''
    # Run fastfetch on terminal start (but not in non-interactive shells)
    if [[ $- == *i* ]]; then
      ${pkgs.fastfetch}/bin/fastfetch --config /etc/fastfetch/config.jsonc
    fi
  '';
}
