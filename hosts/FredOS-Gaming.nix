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
      vesktop
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
      (vscodium.overrideAttrs (old: {
        postFixup = (old.postFixup or "") + ''
          workbenchHtml="$out/lib/vscode/resources/app/out/vs/code/electron-browser/workbench/workbench.html"
          if [ -f "$workbenchHtml" ]; then
            substituteInPlace "$workbenchHtml" \
              --replace-fail '</head>' '<style>.monaco-workbench .part.titlebar { display: none !important; }</style></head>'
          fi
        '';
      }))
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
