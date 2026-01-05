# hosts/FredOS-Gaming.nix
{ config, pkgs, lib, ... }:
{
  config = lib.mkIf (config.networking.hostName == "FredOS-Gaming") {
    environment.systemPackages = with pkgs; [
      lutris
      heroic
    ];
    
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      package = pkgs.steam.override {
        extraPkgs = pkgs: with pkgs; [
          adwaita-icon-theme
        ];
      };
    };
    
    # Steam icon fix script
    systemd.user.services.steam-icon-fix = {
      description = "Fix Steam Proton game icons";
      
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = false;
      };
      
      script = ''
        STEAM_DIR="$HOME/.local/share/Steam"
        DESKTOP_DIR="$HOME/.local/share/applications"
        ICON_DIR="$HOME/.local/share/icons"
        
        # Search all desktop files for steam_icon references
        ${pkgs.gnugrep}/bin/grep -l "Icon=steam_icon_" "$DESKTOP_DIR"/*.desktop 2>/dev/null | while read desktop_file; do
            # Extract the app_id from the Icon line
            app_id=$(${pkgs.gnugrep}/bin/grep "Icon=steam_icon_" "$desktop_file" | ${pkgs.gnused}/bin/sed 's/Icon=steam_icon_//')
            
            # Check if icon already exists
            if [ -f "$ICON_DIR/hicolor/256x256/apps/steam_icon_$app_id.png" ]; then
                continue
            fi
            
            # Find the actual icon file
            icon_file=$(find "$STEAM_DIR/appcache/librarycache/$app_id" -name "*.jpg" 2>/dev/null | head -n 1)
            
            if [ -f "$icon_file" ]; then
                # Copy icon to multiple sizes
                for size in 48x48 64x64 128x128 256x256; do
                    mkdir -p "$ICON_DIR/hicolor/$size/apps/"
                    cp "$icon_file" "$ICON_DIR/hicolor/$size/apps/steam_icon_$app_id.png"
                done
                
                echo "Fixed icon for $(basename "$desktop_file"): App ID $app_id"
            fi
        done
      '';
    };
    
    # Bootloader
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
    boot.loader.timeout = 1;
    
    system.autoUpgrade = {
      enable = true;
      dates = "daily";
      persistent = true;
      allowReboot = false;
      channel = "https://nixos.org/channels/nixos-unstable";
      flags = [
        "--upgrade"
        "--option" "tarball-ttl" "0"
      ];
    };
  };
}
