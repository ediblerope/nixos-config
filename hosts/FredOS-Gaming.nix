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
      wantedBy = [ "default.target" ];
      after = [ "graphical-session.target" ];
      
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = false;
      };
      
      script = ''
        STEAM_DIR="$HOME/.local/share/Steam"
        DESKTOP_DIR="$HOME/.local/share/applications"
        
        # Wait a bit for Steam to create desktop files
        sleep 5
        
        for desktop_file in "$DESKTOP_DIR"/steam_app_*.desktop; do
            [ -f "$desktop_file" ] || continue
            
            app_id=$(basename "$desktop_file" | sed 's/steam_app_\(.*\)\.desktop/\1/')
            icon_file=$(find "$STEAM_DIR/appcache/librarycache/$app_id" -name "*.jpg" 2>/dev/null | head -n 1)
            
            if [ -f "$icon_file" ]; then
                ${pkgs.gnused}/bin/sed -i "s|Icon=steam_icon_$app_id|Icon=$icon_file|" "$desktop_file"
                echo "Fixed icon for App ID: $app_id"
            fi
        done
      '';
    };
    
    # Path watcher to trigger the fix when desktop files change
    systemd.user.paths.steam-icon-fix-watcher = {
      wantedBy = [ "default.target" ];
      pathConfig = {
        PathChanged = "%h/.local/share/applications";
        Unit = "steam-icon-fix.service";
      };
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
