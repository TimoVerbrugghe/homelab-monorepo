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

    # Custom steam intro videos (need to add a .keep file in order for the empty uioverrides directory to be created)
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

    # PS3 ROM File shortcuts for RPCS3
    "ROMs/ps3/Ratchet & Clank Future： A Crack In Time.desktop" = {
      text = ''
      [Desktop Entry]
      Encoding=UTF-8
      Version=1.0
      Type=Application
      Terminal=false
      Exec="${pkgs.rpcs3}/bin/.rpcs3-wrapped" --no-gui "%%RPCS3_GAMEID%%:NPUA80966"
      Name=Ratchet & Clank Future: A Crack In Time
      Categories=Application;Game
      Comment=Ratchet & Clank Future: A Crack In Time
      Icon=/home/gamer/.config/rpcs3/Icons/game_icons/NPUA80966/shortcut.png
      '';
    };

    "ROMs/ps3/Ratchet & Clank® Future： Quest for Booty™.desktop" = {
      text = ''
        [Desktop Entry]
        Encoding=UTF-8
        Version=1.0
        Type=Application
        Terminal=false
        Exec="${pkgs.rpcs3}/bin/.rpcs3-wrapped" --no-gui "%%RPCS3_GAMEID%%:NPUA80145"
        Name=Ratchet & Clank® Future: Quest for Booty™
        Categories=Application;Game
        Comment=Ratchet & Clank® Future: Quest for Booty™
        Icon=/home/gamer/.config/rpcs3/Icons/game_icons/NPUA80145/shortcut.png
      '';
    };

    "ROMs/ps3/Ratchet and Clank® Future： Tools of Destruction™.desktop" = {
      text = ''
        [Desktop Entry]
        Encoding=UTF-8
        Version=1.0
        Type=Application
        Terminal=false
        Exec="${pkgs.rpcs3}/bin/.rpcs3-wrapped" --no-gui "%%RPCS3_GAMEID%%:NPUA80965"
        Name=Ratchet and Clank® Future: Tools of Destruction™
        Categories=Application;Game
        Comment=Ratchet and Clank® Future: Tools of Destruction™
        Icon=/home/gamer/.config/rpcs3/Icons/game_icons/NPUA80965/shortcut.png
      '';
    };

    "ROMs/ps3/Ratchet & Clank™： Going Commando.desktop" = {
      text = ''
        [Desktop Entry]
        Encoding=UTF-8
        Version=1.0
        Type=Application
        Terminal=false
        Exec="${pkgs.rpcs3}/bin/.rpcs3-wrapped" --no-gui "%%RPCS3_GAMEID%%:NPUA80644"
        Name=Ratchet & Clank™: Going Commando
        Categories=Application;Game
        Comment=Ratchet & Clank™: Going Commando
        Icon=/home/gamer/.config/rpcs3/Icons/game_icons/NPUA80644/shortcut.png
      '';
    };

    "ROMs/ps3/Ratchet & Clank™： Up Your Arsenal.desktop" = {
      text = ''
        [Desktop Entry]
        Encoding=UTF-8
        Version=1.0
        Type=Application
        Terminal=false
        Exec="${pkgs.rpcs3}/bin/.rpcs3-wrapped" --no-gui "%%RPCS3_GAMEID%%:NPUA80645"
        Name=Ratchet & Clank™: Up Your Arsenal
        Categories=Application;Game
        Comment=Ratchet & Clank™: Up Your Arsenal
        Icon=/home/gamer/.config/rpcs3/Icons/game_icons/NPUA80645/shortcut.png
      '';
    };

    # Custom configuration for Emulationstation-DE Emulators
    "ES-DE/custom_systems/es_systems.xml" = {
      source = ./dotfiles/es_systems.xml;
      recursive = true;
    };

    "ES-DE/custom_systems/es_find_rules.xml" = {
      source = ./dotfiles/es_find_rules.xml;
      recursive = true;
    };

    # Install overlays
    ".config/retroarch/overlays" = {
      source = ./dotfiles/overlays;
      recursive = true;
    };

    # Set up overlay configuration per core
    ".config/retroarch/config/Snes9x/Snes9x.cfg" = {
      text = ''
        input_overlay_enable ="true"
        input_overlay = "/home/gamer/.config/retroarch/overlays/consoles/snesplain.cfg"
      '';
    };

    ".config/retroarch/config/Flycast/Flycast.cfg" = {
      text = ''
        input_overlay_enable ="true"
        input_overlay = "/home/gamer/.config/retroarch/overlays/consoles/DCPLAIN1.cfg"
      '';
    };

    ".config/retroarch/config/Genesis Plus GX/Genesis Plus GX.cfg" = {
      text = ''
        input_overlay_enable ="true"
        input_overlay = "/home/gamer/.config/retroarch/overlays/consoles/genesisplain.cfg"
      '';
    };

    ".config/retroarch/config/Mupen64Plus-Next/Mupen64Plus-Next.cfg" = {
      text = ''
        input_overlay_enable ="true"
        input_overlay = "/home/gamer/.config/retroarch/overlays/consoles/n64plain.cfg"
      '';
    };

    ".config/retroarch/config/Nestopia/Nestopia.cfg" = {
      text = ''
        input_overlay_enable ="true"
        input_overlay = "/home/gamer/.config/retroarch/overlays/consoles/nesplain.cfg"
      '';
    };


  };
}