{ config, pkgs, pkgs-stable, nixpkgs, ... }:

{

  # Need this for emulationstation-de
  nixpkgs.config.permittedInsecurePackages = [
    "freeimage-3.18.0-unstable-2024-04-18"
  ];

  environment.systemPackages = with pkgs; [
    # Retroarch and cores
    (retroarch.withCores (cores: with cores; [
      nestopia
      genesis-plus-gx
      snes9x
      flycast
      mupen64plus
    ]))

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

    # Change lime3ds with azahar
    azahar
    # A replacement for yuzu
    ryujinx

  ];

}