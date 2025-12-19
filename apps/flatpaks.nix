{ config, pkgs, ... }:

let
  nix-flatpak = builtins.fetchTarball {
    url = "https://github.com/gmodena/nix-flatpak/archive/main.tar.gz";
  };
in
{
  imports = [
    # Pointing to the specific sub-folder path
    "${nix-flatpak}/modules/nixos.nix"
  ];
  
  services.flatpak = {
    enable = true;
    # This matches the options provided by the nix-flatpak module
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
