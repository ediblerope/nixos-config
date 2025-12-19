# flatpaks.nix
{ config, pkgs, ... }:
{
  imports = [
    <nix-flatpak/nixos.nix>
  ];
  
  services.flatpak = {
    enable = true;
    packages = [
      "io.github.zen_browser.zen"
    ];
    overrides = {
      "io.github.zen_browser.zen" = {
        Context.filesystems = [ "home:rw" ];
      };
    };
  };
}
