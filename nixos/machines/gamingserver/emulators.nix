{ config, pkgs, ... }:

{

  environment.systemPackages = with pkgs; [
    retroarchFull
    duckstation
    cemu
    dolphin-emu
    melonDS
    rpcs3
    mgba
    pcsx2
    ppsspp
    # emulationstation-de
    ryujinx

    # Current emulationstation-de is old (2.2.1), so temporarily building the package 3.0.1 myself using the commit https://github.com/NixOS/nixpkgs/pull/299298 until it's pulled
    (pkgs.callPackage ./emulationstation-de/package.nix {})
  ];

  # Need this for emulationstation-de
  nixpkgs.config.permittedInsecurePackages = [
    "freeimage-unstable-2021-11-01"
  ];

}