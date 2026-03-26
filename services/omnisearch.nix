{ config, lib, pkgs, ... }:

let
  omnisearch = builtins.fetchTarball {
    url = "https://git.bwaaa.monster/omnisearch/snapshot/omnisearch-master.tar.gz";
  };
in
{
  imports = [ "${omnisearch}/module.nix" ];

  config = lib.mkIf (config.networking.hostName == "FredOS-Mediaserver") {
    services.omnisearch.enable = true;
  };
}
