{ config, pkgs, ... }:

{
  # Enable git & sgdisk for partitioning and installing from github flakes later
  # Enabling unfree packages for google-chrome
  nixpkgs.config.allowUnfree = true;

  ## Additional packages
  environment.systemPackages = with pkgs; [
    (google-chrome.override {
      commandLineArgs = [
        "--enable-features=VaapiVideoDecodeLinuxGL"
        "--enable-features=TouchpadOverscrollHistoryNavigation" # Enable touchpad back/forward navigation
        "--ozone-platform=wayland" # Enable zoom in with 2 fingers touchpad
      ];
    })
    p7zip
    bitwarden-desktop
    vscode
    nano
    git
    gptfdisk
    evtest
    lm_sensors
    vlc
    plexamp
    plex-media-player
    slack
    moonlight-qt
  ];

  programs.java.enable = true; 
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
  };

}
