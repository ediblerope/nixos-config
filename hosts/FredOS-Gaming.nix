# hosts/FredOS-Gaming.nix
{ config, pkgs, lib, inputs, ... }:
{
  config = lib.mkIf (config.networking.hostName == "FredOS-Gaming") {
    environment.systemPackages = with pkgs; [
      lutris
      #(heroic.override {
      #  extraPkgs = pkgs: with pkgs; [
      #    adwaita-icon-theme
      #  ];
      #})
      mangohud
      (goofcord.overrideAttrs (old: {
        postFixup = (old.postFixup or "") + ''
          substituteInPlace $out/bin/goofcord \
            --replace-fail '/bin/electron"' '/bin/electron" --class=GoofCord'
        '';
      }))
      lsfg-vk
      lsfg-vk-ui
      faugus-launcher
      adwaita-icon-theme
      mission-center
      geary
      wowup-cf
      adwsteamgtk
      proton-vpn
      onlyoffice-desktopeditors
      vscodium
    ];

    programs.nix-ld.enable = true;

    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      package = pkgs.steam.override {
        extraPkgs = pkgs: with pkgs; [
          adwaita-icon-theme
        ];
      };
    };

    boot.loader.systemd-boot.configurationLimit = 5;
    boot.initrd.systemd.enable = true;
  };
}
