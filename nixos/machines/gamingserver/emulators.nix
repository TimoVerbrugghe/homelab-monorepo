{ config, pkgs, ... }:

{

  environment.systemPackages = with pkgs; [
    retroarch-full
    duckstation
    cemu
    dolphin-emu
    melonDS
    rpcs3
    mgba
    pcsx2
    ppsspp-sdl-wayland
    emulationstation-de
    xemu
    wineWowPackages.full
    # _86Box-with-roms
    winetricks
    steam-rom-manager

    # Trying to build ppsspp without the system_ffmpeg flag because getting severe graphical glitches
    # (pkgs.callPackage ./ppsspp-standard-ffmpeg/package.nix {})

    # Current 86Box is old (4.1) and I need to wrap the 86Box program with env variable QT_QPA_PLATFORM=xcb in order for 86Box mouse capture to work
    (pkgs.callPackage ./86Box-git/package.nix {})

    # Installing citra, source (AppImage) has to be provided yourself
    (pkgs.callPackage ./citra/package.nix {})

    # Installing ryujinx, source (AppImage) has to be provided yourself
    (pkgs.callPackage ./ryujinx/package.nix {})
  ];

  # Need this for emulationstation-de
  nixpkgs.config.permittedInsecurePackages = [
    "freeimage-unstable-2021-11-01"
  ];

}