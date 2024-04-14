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
    # Input remapper config files to enable L3+R3 -> Alt-F4 conversion
    ".config/input-remapper-2" = {
      source = ./dotfiles/input-remapper-2;
      recursive = true;
    };

    # Input Remapper autoload desktop file placed in autostart so that it autostarts on login
    ".config/autostart/input-remapper-autoload.desktop" = {
      text = ''
        [Desktop Entry]
        Type=Application
        Exec=bash -c "input-remapper-control --command stop-all && input-remapper-control --command autoload"
        Name=input-remapper-autoload
        Icon=/usr/share/input-remapper/input-remapper.svg
        Comment=Starts injecting all presets that are set to automatically load for the user
      '';
    };

    ".steam/root/config/uioverrides/.keep" = {
      text = ''
        DO NOT DELETE THIS FILE
      '';
      recursive = true;
    };

    ".steam/root/config/uioverrides/movies" = {
      source = ./steamstartupvideos;
      recursive = true;
    };

    # Tested and need this file for faster Steam downloads - see https://www.reddit.com/r/linux_gaming/comments/16e1l4h/slow_steam_downloads_try_this/
    ".steam/steam/steam_dev.cfg" = {
      text = ''
        @fDownloadRateImprovementToAddAnotherConnection 1.0
        @nClientDownloadEnableHTTP2PlatformLinux 0
      '';
      recursive = true;
    };
  };
}