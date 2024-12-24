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
    # ppsspp-sdl-wayland
    emulationstation-de
    xemu
    wineWowPackages.full
    # _86Box-with-roms
    winetricks
    steam-rom-manager

    # Trying to build ppsspp without the system_ffmpeg flag because getting severe graphical glitches
    (pkgs.callPackage ./ppsspp-standard-ffmpeg/package.nix {})

    # # Current emulationstation-de is old (2.2.1), so temporarily building the package 3.0.1 myself using the commit https://github.com/NixOS/nixpkgs/pull/299298 until it's pulled
    # (pkgs.callPackage ./emulationstation-de/package.nix {})

    # Current 86Box is old (4.1) and I need to wrap the 86Box program with env variable QT_QPA_PLATFORM=xcb in order for 86Box mouse capture to work
    (pkgs.callPackage ./86Box-git/package.nix {})

    # Installing citra, source has to be provided yourself
    (pkgs.qt6Packages.callPackage ./citra/package.nix {})

    # Installing ryujinx, source has to be provided yourself
    (pkgs.callPackage ./ryujinx/package.nix {})
  ];

  # Need this for emulationstation-de
  nixpkgs.config.permittedInsecurePackages = [
    "freeimage-unstable-2021-11-01"
  ];

}