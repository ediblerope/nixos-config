#./apps/helium.nix
{ inputs, pkgs, lib, config, ... }:
{
  config = lib.mkIf (lib.elem config.networking.hostName [ "FredOS-Gaming" "FredOS-Macbook" ]) {
    environment.systemPackages = [
      inputs.helium.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];

    # Chromium policies for Helium (Chromium-based)
    programs.chromium = {
      enable = true;
      extensions = [
        "ghmbeldphafepmbegfdlkpapadhbakde" # Proton Pass
      ];
      extraOpts = {
        PasswordManagerEnabled = false;
        AutofillCreditCardEnabled = false;
        AutofillAddressEnabled = false;
      };
    };
  };
}
