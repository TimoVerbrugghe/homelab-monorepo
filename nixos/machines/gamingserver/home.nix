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

    # Emulation Station Desktop Edition autostart desktop file
    ".config/autostart/emulationstation.desktop" = {
      text = ''
        [Desktop Entry]
        Type=Application
        Exec=es-de
        Name=Emulation Station DE
        Comment=Front-end for retro gaming
        Icon=emulationstation
      '';
    };

    # Add steam to ROMs folder so that it can be launched from Emulation Station
    "ROMs/windows/steam.desktop" = {
      text = ''
        [Desktop Entry]
        Type=Application
        Name=Steam
        Exec=steam steam://open/bigpicture
        Icon=steam
        Categories=Game;
      '';
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

    "ROMs/windows/harry-potter-and-the-sorcerer-stone.desktop" = {
      text = ''
        [Desktop Entry]
        Name=Harry Potter and the Philosopher's Stone
        Exec=env WINEPREFIX=/home/gamer/lutrisgames/harry-potter-and-the-philosophers-stone wine start /unix "/home/gamer/lutrisgames/harry-potter-and-the-philosophers-stone/drive_c/Program Files (x86)/EA Games/Harry Potter TM/System/HP.exe"
        Type=Application
        Categories=Game
      '';
    };

    "ROMs/windows/harry-potter-and-the-chamber-of-secrets.desktop" = {
      text = ''
        [Desktop Entry]
        Name=Harry Potter and the Chamber of Secrets
        Exec=env WINEPREFIX=/home/gamer/lutrisgames/harry-potter-and-the-chamber-of-secrets wine start /unix "/home/gamer/lutrisgames/harry-potter-and-the-chamber-of-secrets/drive_c/Program Files (x86)/EA Games/Harry Potter and the Chamber of Secrets/system/HP2.exe"
        Type=Application
        Categories=Game
      '';
    };

    "ROMs/windows/minecraft-story-mode-season-2.desktop" = {
      text = ''
        [Desktop Entry]
        Type=Application
        Name=Minecraft Story Mode Season 2
        Icon=lutris_minecraft-story-mode-season-2
        Exec=env LUTRIS_SKIP_INIT=1 lutris lutris:rungame/minecraft-story-mode-season-2
        Categories=Game
      '';
    };

    "ROMs/windows/miel-monteur-vliegt-de-wereld-rond.desktop" = {
      text = ''
        [Desktop Entry]
        Type=Application
        Name=Miel Monteur Vliegt De Wereld Rond
        Icon=lutris_miel-monteur-vliegt-de-wereld-rond
        Exec=env LUTRIS_SKIP_INIT=1 lutris lutris:rungame/miel-monteur-vliegt-de-wereld-rond
        Categories=Game
      '';
    };

    "ROMs/windows/miel-monteur-huis-op-stelten.desktop" = {
      text = ''
        [Desktop Entry]
        Type=Application
        Name=Miel Monteur Huis op Stelten
        Icon=lutris_miel-monteur-huis-op-stelten
        Exec=env LUTRIS_SKIP_INIT=1 lutris lutris:rungame/miel-monteur-huis-op-stelten
        Categories=Game
      '';
    };

    "ROMs/windows/miel-monteur-verkent-de-ruimte.desktop" = {
      text = ''
        [Desktop Entry]
        Type=Application
        Name=Miel Monteur Huis op Stelten
        Icon=lutris_miel-monteur-verkent-de-ruimte
        Exec=env LUTRIS_SKIP_INIT=1 lutris lutris:rungame/miel-monteur-verkent-de-ruimte
        Categories=Game
      '';
    };

    "ROMs/windows/miel-monteur-bouwt-autos.desktop" = {
      text = ''
        [Desktop Entry]
        Type=Application
        Name=Miel Monteur Bouwt Auto's
        Exec=86Box --config /home/gamer/ROMs/windows/mielmonteur1/86Boxconfig.cfg --rompath /home/gamer/ROMs/windows/mielmonteur1/roms --fullscreen
        Categories=Game
        Path=/home/gamer/ROMs/windows/mielmonteur1
      '';
    };

    "ROMs/windows/miel-monteur-recht-door-zee.desktop" = {
      text = ''
        [Desktop Entry]
        Type=Application
        Name=Miel Monteur Recht Door Zee!
        Exec=86Box --config /home/gamer/ROMs/windows/mielmonteur2/86Boxconfig.cfg --rompath /home/gamer/ROMs/windows/mielmonteur2/roms --fullscreen
        Categories=Game
        Path=/home/gamer/ROMs/windows/mielmonteur2
      '';
    };

    "ROMs/windows/boeboeks-tocht-naar-opa-kakadoris.desktop" = {
      text = ''
        [Desktop Entry]
        Type=Application
        Name=Boeboeks - De Tocht Naar Opa Kakadoris
        Exec=86Box --config /home/gamer/ROMs/windows/boeboeks/86Boxconfig.cfg --rompath /home/gamer/ROMs/windows/boeboeks/roms --fullscreen
        Categories=Game
        Path=/home/gamer/ROMs/windows/boeboeks
      '';
    };

    "ROMs/windows/skippy-geheim-van-de-gestolen-papyrusrol.desktop" = {
      text = ''
        [Desktop Entry]
        Type=Application
        Name=Skippy en Het Geheim van de Gestolen Papyrusrol
        Exec=86Box --config /home/gamer/ROMs/windows/skippy/86Boxconfig.cfg --rompath /home/gamer/ROMs/windows/skippy/roms --fullscreen
        Categories=Game
        Path=/home/gamer/ROMs/windows/skippy
      '';
    };

    ".local/share/applications/org.es_de.frontend.desktop" = {
      text = ''
        [Desktop Entry]
        Version=1.0
        Exec=es-de
        Icon=es-de
        Terminal=false
        Type=Application
        StartupNotify=true
        Hidden=false
        Categories=Game;Emulator;
        Name=EmulationStation Desktop Edition
        GenericName=Gaming Frontend
        Keywords=emulator;emulation;front-end;frontend;
      '';
    };

    ".local/share/manifests/emulationstation-manifest.json" = {
      source = ./dotfiles/emulationstation-manifest.json;
      recursive = true;
    };

  };
}