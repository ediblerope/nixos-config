#omnisearch.nix
{ config, lib, pkgs, ... }:

let
  omnisearchSrc = builtins.fetchTarball {
    url = "https://git.bwaaa.monster/omnisearch/snapshot/omnisearch-master.tar.gz";
  };

  beakerSrc = builtins.fetchGit {
    url = "https://git.bwaaa.monster/beaker";
    shallow = true;
  };

  beaker = pkgs.stdenv.mkDerivation {
    pname = "beaker";
    version = "git";
    src = beakerSrc;
    makeFlags = [
      "INSTALL_PREFIX=$(out)/"
      "LDCONFIG=true"
    ];
  };

  omnisearchPkg = pkgs.stdenv.mkDerivation {
    pname = "omnisearch";
    version = "git";
    src = omnisearchSrc;

    buildInputs = [
      pkgs.libxml2.dev
      pkgs.curl.dev
      pkgs.openssl
      beaker
    ];

    preBuild = ''
      makeFlagsArray+=(
        "PREFIX=$out"
        "CFLAGS=-Wall -Wextra -O2 -Isrc -I${pkgs.libxml2.dev}/include/libxml2"
        "LIBS=-lbeaker -lcurl -lxml2 -lpthread -lm -lssl -lcrypto"
      )
    '';

    installPhase = ''
      mkdir -p $out/bin $out/share/omnisearch
      install -Dm755 bin/omnisearch $out/bin/omnisearch
      cp -r templates static -t $out/share/omnisearch/
    '';
  };

  fakeSelf = {
    packages.${pkgs.stdenv.hostPlatform.system}.default = omnisearchPkg;
  };

  omnisearchModule = import "${omnisearchSrc}/module.nix" fakeSelf;
in
{
  imports = [ omnisearchModule ];

  config = lib.mkIf (config.networking.hostName == "FredOS-Mediaserver") {
    services.omnisearch.enable = true;
  };
}
