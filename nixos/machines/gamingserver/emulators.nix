{ config, pkgs, pkgs-stable, nixpkgs, ... }:

{
  
  nixpkgs.overlays = [
    (final: prev: {
      # Import stable channel
      stable = import nixpkgs {
        inherit (final.stdenv.hostPlatform) system;
        inherit (final) config;
      };
      
      # Override just emulationstation-de to use stable libgit2
      emulationstation-de = prev.emulationstation-de.override {
        libgit2 = final.stable.libgit2;
      };
    })
  ];


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
    _86Box-with-roms
    winetricks
    steam-rom-manager

    # Trying to build ppsspp without the system_ffmpeg flag because getting severe graphical glitches
    # (pkgs.callPackage ./ppsspp-standard-ffmpeg/package.nix {})

    # Current 86Box is old (4.1) and I need to wrap the 86Box program with env variable QT_QPA_PLATFORM=xcb in order for 86Box mouse capture to work
    # (pkgs.callPackage ./86Box-git/package.nix {})

    # # Installing citra, source (AppImage or source) has to be provided yourself
    # (pkgs.callPackage ./citra/package-appimage.nix {})
    # Instead of citra, you can also install lime3ds - not working in January 2025
    lime3ds

    # Installing ryujinx, source (AppImage or source) has to be provided yourself
    # (pkgs.callPackage ./ryujinx/package-source.nix {})
    # ryujinx

    # A replacement for yuzu & ryujinx
    torzu

  ];

  # Need this for emulationstation-de
  nixpkgs.config.permittedInsecurePackages = [
    "freeimage-unstable-2021-11-01"
  ];

}