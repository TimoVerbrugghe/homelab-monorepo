{ config, pkgs, ... }:

{
  programs.java.enable = true; 
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
  };

  ## TO DO: Create steam_dev.cfg file that ensures that steam downloads are ok
}