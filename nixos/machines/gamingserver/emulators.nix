{ config, pkgs, pkgs-stable, nixpkgs, ... }:

{
  
  nixpkgs.overlays = [
    (final: prev: {
      # Import stable channel for packages from nixpkgs-stable (flake inputs)
      stable = import nixpkgs {
        inherit (final.stdenv.hostPlatform) system;
        inherit (final) config;
      };

      emulationstation-de = prev.emulationstation-de.overrideAttrs (oldAttrs: {
        # Update the buildInputs to include OpenGL-related dependencies
        buildInputs = let
          filteredInputs = builtins.filter (input:
            !(prev.lib.hasPrefix "libGL" (input.name or ""))
          ) (oldAttrs.buildInputs or []);
        in
          filteredInputs ++ [
            final.libGL
          ];
      });
    })
  ];

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
    # rpcs3
    mgba
    pcsx2
    ppsspp-sdl-wayland
    emulationstation-de
    xemu
    wineWowPackages.full
    _86Box-with-roms
    winetricks
    steam-rom-manager

    # Lime3DS does not compile in the unstable branch
    stable.lime3ds
    # A replacement for yuzu & ryujinx
    torzu

  ];

}