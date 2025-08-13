# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

let
	hostname = "nixos-gaming";
in

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./modules/base.nix
      (./modules + "/${hostname}.nix")  # Uses hostname from environment
      ./modules/kde.nix
      ./modules/krisp-patcher.nix
      #<home-manager/nixos>
    ];
	networking.hostName = "${hostname}";

#######################################################
system.stateVersion = "25.05";
}
