# hosts/FredOS-Gaming.nix
{ config, pkgs, lib, ... }:
{
  config = lib.mkIf (config.networking.hostName == "FredOS-Gaming") {
    environment.systemPackages = with pkgs; [
      lutris
    ];
    
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      package = pkgs.steam.override {
        extraPkgs = pkgs: with pkgs; [
          kdePackages.breeze
        ];
      };
    };
    
    system.autoUpgrade = {
      enable = true;
      dates = "daily";
      persistent = true;
      allowReboot = false;
      flags = [
        "--upgrade"
        "--option" "tarball-ttl" "0"
      ];
    };
  };
}
