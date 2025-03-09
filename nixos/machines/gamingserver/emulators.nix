{ config, pkgs, pkgs-stable, nixpkgs, ... }:

{
  
nixpkgs.overlays = [
  (final: prev: {
    # Import stable channel
    stable = import nixpkgs {
      inherit (final.stdenv.hostPlatform) system;
      inherit (final) config;
    };
    
    # Create a fixed version of emulationstation-de
    emulationstation-de = prev.emulationstation-de.overrideAttrs (oldAttrs: {
      # Add stable dev packages for headers
      nativeBuildInputs = (oldAttrs.nativeBuildInputs or []) ++ [
        final.stable.pkg-config
        final.stable.sysprof # For sysprof-capture-4
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
          # Add both runtime and dev versions of ICU
          final.stable.icu
          (final.stable.icu.override { withDev = true; })
          # Add glib with sysprof explicitly
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
        "-DICU_I18N_LIBRARY_RELEASE=${final.stable.icu}/lib/libicui18n${final.stdenv.hostPlatform.extensions.sharedLibrary}"
        "-DICU_UC_LIBRARY_RELEASE=${final.stable.icu}/lib/libicuuc${final.stdenv.hostPlatform.extensions.sharedLibrary}"
        "-DICU_DATA_LIBRARY_RELEASE=${final.stable.icu}/lib/libicudata${final.stdenv.hostPlatform.extensions.sharedLibrary}"
      ];
      
      # Add environment variables for pkg-config to find the right dependencies
      preConfigure = (oldAttrs.preConfigure or "") + ''
        export PKG_CONFIG_PATH="${final.stable.sysprof}/lib/pkgconfig:${final.stable.glib.dev}/lib/pkgconfig:$PKG_CONFIG_PATH"
      '';
    });
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