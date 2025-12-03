{ config, pkgs, lib, ... }:

{
config = lib.mkIf (config.networking.hostName == "FredOS-Gaming") {
	
	# List packages installed in system profile. To search, run:
	# $ nix search wget
	environment.systemPackages = with pkgs; [
		#Package name
		lutris
	];
	programs.steam = {
  		enable = true;
  		remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
  		dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  		localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
	};
	
};
}
