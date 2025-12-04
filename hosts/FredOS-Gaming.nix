{ config, pkgs, lib, ... }:
{
  config = lib.mkIf (config.networking.hostName == "FredOS-Gaming") {
    imports = [
      ../settings/gnome.nix
    ];
    
    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs; [
      #Package name
      lutris
    ];
    
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      package = pkgs.steam.override {
        extraPkgs =
          pkgs: with pkgs; [
            kdePackages.breeze
          ];
      };
    };
    
    system.autoUpgrade = {
      enable = true;
      dates = "daily";
      persistent = true;  # Run on next boot if the scheduled time was missed
      allowReboot = false;
      flags = [
        "--upgrade"
        "--option" "tarball-ttl" "0"
      ];
    };
  };
}
