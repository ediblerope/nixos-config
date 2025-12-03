# Define a user account. Don't forget to set a password with ‘passwd’.
users.users.fred = {
    isNormalUser = true;
    description = "fred";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      bazaar
      fastfetch
    ];
  };
