{ config, pkgs, ... }:

{

  ## STEAM ##
  programs.java.enable = true; 
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    gamescopeSession.enable = true;
  };

  environment.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS =
      "/home/gamer/.steam/root/compatibilitytools.d";
  };

  ## ADDITIONAL LAUNCHERS AND TOOLS ##
  environment.systemPackages = with pkgs; [
    mangohud
    # Install Proton-GE (a more extended, better version of proton)
    protonup
    lutris
    heroic
  ];
}