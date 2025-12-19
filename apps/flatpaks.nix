{ config, pkgs, ... }:

let
  # This fetches the code directly from GitHub without needing a 'channel'
  nix-flatpak = builtins.fetchTarball {
    url = "https://github.com/gmodena/nix-flatpak/archive/main.tar.gz";
    # You can add a sha256 here for security later
  };
in
{
  imports = [
    "${nix-flatpak}/nixos.nix"
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
