{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  pname = "discord-capture-limiter";
  version = "0.1.0";

  src = pkgs.fetchFromGitHub {
    owner = "ediblerope";
    repo = "Discord-Capture-Limiter";
    rev = "v0.1.0";  # or commit hash
    sha256 = "sha256-hash-goes-here";
  };

  buildInputs = [ pkgs.makeWrapper ];
  installPhase = ''
    mkdir -p $out/bin
    cp path/to/your/script $out/bin/discord-capture-limiter
    chmod +x $out/bin/discord-capture-limiter
  '';
}
