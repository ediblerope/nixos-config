#omnisearch.nix
{ config, lib, pkgs, ... }:

let
  omnisearch = builtins.fetchTarball {
    url = "https://git.bwaaa.monster/omnisearch/archive/master.tar.gz";
  };
in
{
  imports = [ "${omnisearch}/module.nix" ];

  services.omnisearch.enable = true;
}
