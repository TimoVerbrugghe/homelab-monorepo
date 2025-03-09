{ config, pkgs, pkgs-stable, nixpkgs, ... }:

{
  
  # # Changes to nixpkgs-unstable in order to allow building of NixOS for my gamingserver
	# nixpkgs.overlays = [
  #   (final: _: {
  #     # this allows you to access `pkgs.stable` anywhere in your config
  #     # Needed for a.o. lime3ds which has issues building in unstable
  #     stable = import nixpkgs {
  #       inherit (final.stdenv.hostPlatform) system;
  #       inherit (final) config;
  #     };

  #     # Point the package libgit2 to nixpkgs stable, needed for emulationstation-de package from unstable to build
	# 		libgit2 = pkgs-stable.libgit2;
  #   })
  # ];


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