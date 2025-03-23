{ config, pkgs, pkgs-stable, nixpkgs, ... }:

{
  
  nixpkgs.overlays = [
    (final: prev: {
      # Import stable channel for packages from nixpkgs-stable (flake inputs)
      stable = import nixpkgs {
        inherit (final.stdenv.hostPlatform) system;
        inherit (final) config;
      };
      
      # Several changes needed to the emulationstation-de package to make it compile on unstable
      # Changes created by Claude AI - https://claude.ai/share/29fa4ca6-c9ba-425f-a500-24e62917c43a
      emulationstation-de = prev.emulationstation-de.overrideAttrs (oldAttrs: {
        # Add stable dev packages for headers
        nativeBuildInputs = (oldAttrs.nativeBuildInputs or []) ++ [
          final.stable.pkg-config
          final.stable.sysprof
        ];
        
        # Use both stable libgit2 and stable icu
        buildInputs = let
          filteredInputs = builtins.filter (input: 
            !(prev.lib.hasPrefix "libgit2" (input.name or "")) && 
            !(prev.lib.hasPrefix "icu" (input.name or ""))
          ) (oldAttrs.buildInputs or []);
        in
          filteredInputs ++ [ 
            final.stable.libgit2
            final.stable.icu
            final.stable.glib
          ];
        
        # Add necessary compiler flags
        NIX_CFLAGS_COMPILE = (oldAttrs.NIX_CFLAGS_COMPILE or "") + " -fpermissive";
        
        # Point to ICU dev files explicitly
        cmakeFlags = (oldAttrs.cmakeFlags or []) ++ [
          "-DLIBGIT2_INCLUDE_DIR=${final.stable.libgit2}/include"
          "-DLIBGIT2_LIBRARIES=${final.stable.libgit2}/lib/libgit2${final.stdenv.hostPlatform.extensions.sharedLibrary}"
          "-DICU_ROOT=${final.stable.icu.dev}"
          "-DICU_INCLUDE_DIR=${final.stable.icu.dev}/include"
          "-DICU_LIBRARY_DIR=${final.stable.icu}/lib"
        ];
        
        # Add environment variables for pkg-config to find the right dependencies
        preConfigure = (oldAttrs.preConfigure or "") + ''
          export PKG_CONFIG_PATH="${final.stable.sysprof}/lib/pkgconfig:${final.stable.glib.dev}/lib/pkgconfig:$PKG_CONFIG_PATH"
        '';
      });
    })
  ];

  # Need this for emulationstation-de
  nixpkgs.config.permittedInsecurePackages = [
    "freeimage-unstable-2021-11-01"
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

    # Lime3DS does not compile in the unstable branch
    stable.lime3ds
    # A replacement for yuzu & ryujinx
    torzu

  ];

}