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
    # Install Proton-GE (a more extended, better version of proton)
    protonup
  ];

  environment.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS =
      "/home/gamer/.steam/root/compatibilitytools.d";
  };

}