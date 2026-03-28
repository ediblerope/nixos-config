# services/omnisearch.nix — add 'inputs' to the args
{ config, pkgs, lib, inputs, ... }:
{
  # replace your fakeSelf tarball fetch with:
  services.omnisearch = {
    package = inputs.omnisearch.packages.${pkgs.stdenv.hostPlatform.system}.default;
  };
}