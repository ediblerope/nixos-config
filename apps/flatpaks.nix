{ config, pkgs, ... }:
{
  imports = [
    <nix-flatpak/modules/nixos.nix>
  ];
  
  services.flatpak = {
    enable = true;
    
    remotes = [
      {
        name = "flathub";
        location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
      }
    ];
    
    packages = [
      "io.github.zen_browser.zen"
      "dev.vencord.Vesktop"
    ];
    
    overrides = {
      "io.github.zen_browser.zen" = {
        Context.filesystems = [ "home:rw" ];
      };
    };
  };
}
