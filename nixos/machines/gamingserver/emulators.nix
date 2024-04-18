{ config, pkgs, ... }:

{

  environment.systemPackages = with pkgs; [
    # Uncomment until https://github.com/NixOS/nixpkgs/pull/303494 is pulled
    # retroarchFull
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

    # Trying to build ppsspp without the system_ffmpeg flag because getting severe graphical glitches
    (pkgs.callPackage ./ppsspp-standard-ffmpeg/package.nix {})

    # Current emulationstation-de is old (2.2.1), so temporarily building the package 3.0.1 myself using the commit https://github.com/NixOS/nixpkgs/pull/299298 until it's pulled
    (pkgs.callPackage ./emulationstation-de/package.nix {})

    (pkgs.qt6Packages.callPackage ./citra/package.nix rec {
      pname = "citra-nightly";
      version = "2088";

      src = source;
    })
  ];

  # Need this for emulationstation-de
  nixpkgs.config.permittedInsecurePackages = [
    "freeimage-unstable-2021-11-01"
  ];

}