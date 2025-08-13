{ config, lib, pkgs, ... }:

{

imports =
    [ # Include the results of the hardware scan.
      ./apps.nix
    ];

# Bootloader needed for gaming PC
boot.loader = {
	systemd-boot.enable = true;
	efi = {
		canTouchEfiVariables = true;
		#efiSysMountPoint = "/boot/efi";
	};
};

# Prevent mount point failures from stopping boot
systemd.services.check-mountpoints.enable = false;

# Steam
programs.steam = {
	enable = true;
	remotePlay.openFirewall = true;
	package = pkgs.steam.override {
        extraPkgs =
          pkgs: with pkgs; [
            kdePackages.breeze
          ];
	};
};


programs.gamescope.enable = true;
programs.gamemode.enable = true;

# Jellyfin service
services.jellyfin = {
	enable = true;
	openFirewall = true;
};

# Noisetorch
programs.noisetorch.enable = true;

#maybe kernel video
boot.kernelParams = [ "video=DP-2:1920x1080@144"];

# Mount torrent drive
fileSystems."/mnt/windows" = {
device = "/dev/disk/by-uuid/64AE6FC8AE6F90FA";
fsType = "ntfs";
options = [
	"rw"
	"uid=1000"
	"gid=100"
	"nofail"
	"windows_names"
];
};
############


}
