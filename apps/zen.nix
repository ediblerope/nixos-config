#./apps/zen.nix
#{ inputs, pkgs, lib, config,  ... }:
#{
#    config = lib.mkIf (lib.elem config.networking.hostName [ "FredOS-Gaming" "FredOS-Macbook" ]) {
#        environment.systemPackages = [
#            (pkgs.wrapFirefox
#            inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.zen-browser-unwrapped
#            {
#                extraPolicies = {
#                DisableTelemetry = true;
#                };
#            }
#            )   
#        ];
#    };
#}

{ inputs, pkgs, lib, config, ... }:
{
  config = lib.mkIf (lib.elem config.networking.hostName [ "FredOS-Gaming" "FredOS-Macbook" ]) {
    environment.systemPackages = [
      inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
  };
}