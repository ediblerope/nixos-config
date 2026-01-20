{ config, pkgs, ... }:
{
  imports = [
    <nix-flatpak/modules/nixos.nix>
  ];

config = lib.mkIf (lib.elem config.networking.hostName [ "FredOS-Gaming" "FredOS-Macbook" ]) {
  
  services.flatpak = {
    enable = true;
    
    remotes = [
      {
        name = "flathub";
        location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
      }
    ];
    
    packages = [
      "app.zen_browser.zen"
      #"dev.vencord.Vesktop"
    ];
    
    overrides = {
      "app.zen_browser.zen" = {
        Context.filesystems = [ "home:rw" ];
      };
      #"dev.vencord.Vesktop" = {
      #  Context.filesystems = [ "home:rw" ];
      #};
    };
  };
};
}
