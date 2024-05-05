{ config, pkgs, ... }:

{
  programs.java.enable = true; 
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    gamescopeSession.enable = true;
  };

  environment.systemPackages = with pkgs; [
    mangohud
  ];
}