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
      "app.zen_browser.zen"
      "org.equicord.equibop"
    ];
    
    overrides = {
      "app.zen_browser.zen" = {
        Context.filesystems = [ "home:rw" ];
      };
      "org.equicord.equibop" = {
        Context.filesystems = [ "home:rw" ];
      };
    };
  };
}
