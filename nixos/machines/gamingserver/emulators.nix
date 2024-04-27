{ config, pkgs, ... }:

{

  environment.systemPackages = with pkgs; [
    (retroarch.override {
      cores = with libretro; [
        genesis-plus-gx # Genesis
        snes9x # SNES
        flycast # Dreamcast
        nestopia # NES
        mupen64plus # N64
      ];
    })
    duckstation
    cemu
    dolphin-emu
    melonDS
    rpcs3
    mgba
    pcsx2
    # ppsspp-sdl-wayland
    # emulationstation-de
    ryujinx
    xemu
    lutris
    wineWowPackages.full
    # _86Box-with-roms
    winetricks
    steam-rom-manager
    gamescope

    # Trying to build ppsspp without the system_ffmpeg flag because getting severe graphical glitches
    (pkgs.callPackage ./ppsspp-standard-ffmpeg/package.nix {})

    # Current emulationstation-de is old (2.2.1), so temporarily building the package 3.0.1 myself using the commit https://github.com/NixOS/nixpkgs/pull/299298 until it's pulled
    (pkgs.callPackage ./emulationstation-de/package.nix {})

    # Current 86Box is old (4.1) and I need to wrap the 86Box program with env variable QT_QPA_PLATFORM=xcb in order for 86Box mouse capture to work
    (pkgs.callPackage ./86Box-git/package.nix {})

    # Installing citra, source has to be provided yourself
    (pkgs.qt6Packages.callPackage ./citra/package.nix {})
  ];

  # Need this for emulationstation-de
  nixpkgs.config.permittedInsecurePackages = [
    "freeimage-unstable-2021-11-01"
  ];

}