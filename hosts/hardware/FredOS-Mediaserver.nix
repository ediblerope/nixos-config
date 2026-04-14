#./hosts/hardware/FredOS-Mediaserver.nix
# TODO: Replace with hardware-configuration.nix from new server
{ config, lib, pkgs, modulesPath, ... }:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  networking.hostName = "FredOS-Mediaserver";
  system.stateVersion = "25.11";
}
