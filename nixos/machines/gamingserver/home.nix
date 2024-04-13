{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "gamer";
  home.homeDirectory = "/home/gamer";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Apparently this is required for home manager
  home.stateVersion = "23.11";

  home.file = {
    ".config/plasmanotifyrc" = {
      text = ''
        [Services][devicenotifications]
        ShowInHistory=false
        ShowPopups=false

        [Services][freespacenotifier]
        ShowInHistory=false
        ShowPopups=false

        [Services][kcm_touchpad]
        ShowInHistory=false
        ShowPopups=false

        [Services][ksmserver]
        ShowInHistory=false
        ShowPopups=false

        [Services][kwalletd5]
        ShowInHistory=false
        ShowPopups=false

        [Services][kwin]
        ShowInHistory=false
        ShowPopups=false

        [Services][kwrited]
        ShowInHistory=false
        ShowPopups=false

        [Services][networkmanagement]
        ShowInHistory=false
        ShowPopups=false

        [Services][org.kde.kded.inotify]
        ShowInHistory=false
        ShowPopups=false

        [Services][phonon]
        ShowInHistory=false
        ShowPopups=false

        [Services][policykit1-kde]
        ShowInHistory=false
        ShowPopups=false

        [Services][powerdevil]
        ShowInHistory=false
        ShowPopups=false

        [Services][printmanager]
        ShowInHistory=false
        ShowPopups=false

        [Services][proxyscout]
        ShowInHistory=false
        ShowPopups=false

        [Services][xdg-desktop-portal-kde]
        ShowInHistory=false
        ShowPopups=false
      '';
    };

    ".steam/root/config/uioverrides/movies" = {
      source = ./steamstartupvideos
    };
  };
}