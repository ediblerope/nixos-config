# hm-config.nix
{ config, pkgs, lib, ... }:

{

imports = [
    <home-manager/nixos>
  ];
  home-manager.users.fred = { pkgs, ... }: {
    imports = [
      ./settings/home.nix # We will create this file next
    ];
  };

}
