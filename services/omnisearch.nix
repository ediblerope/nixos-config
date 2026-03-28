#omnisearch.nix
{ ... }:
{
  config = lib.mkIf (config.networking.hostName == "FredOS-Mediaserver") {
    services.omnisearch.enable = true;
  }
}