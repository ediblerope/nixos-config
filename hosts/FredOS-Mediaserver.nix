{ config, pkgs, lib, ... }:
{
  config = lib.mkIf (config.networking.hostName == "FredOS-Mediaserver") {
    # Create symlink from home to storage
    systemd.tmpfiles.rules = [
      "L+ /home/fred/storage - - - - /mnt/storage"
    ];

    # Basic system packages
    environment.systemPackages = with pkgs; [
      mergerfs
      wget
      btop
      util-linux
      javaPackages.compiler.temurin-bin.jre-25
      unzip
      screen
      yt-dlp
      ghostty.terminfo
      matugen
      (pkgs.writeShellScriptBin "transcode-hevc" ''
        export PATH="${pkgs.jellyfin-ffmpeg}/bin:${pkgs.coreutils}/bin:${pkgs.findutils}/bin:${pkgs.gnugrep}/bin:${pkgs.gawk}/bin:${pkgs.bc}/bin:${pkgs.curl}/bin:$PATH"
        exec ${pkgs.bash}/bin/bash ${../scripts/transcode-hevc.sh} "$@"
      '')
      (pkgs.writeShellScriptBin "record-update" ''
        export PATH="${pkgs.nvd}/bin:${pkgs.coreutils}/bin:${pkgs.gnugrep}/bin:${pkgs.gnused}/bin:$PATH"
        exec ${pkgs.bash}/bin/bash ${../scripts/record-update.sh} "$@"
      '')
    ];

    # Basic networking
    networking.useDHCP = lib.mkDefault true;

    # Open firewall for SSH
    networking.firewall.allowedTCPPorts = [ 22 ];
    services.openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
      };
    };
  };
}
