# Vapor - SteamOS Theme based on KDE Breeze and Breath

{ stdenv, lib, fetchurl, zstd }:

let

  version = "0.28";

in

stdenv.mkDerivation rec {
  pname = "plasma6-vapor-nixos-theme";
  inherit version;
  
  src = fetchurl {
    url = "https://steamdeck-packages.steamos.cloud/archlinux-mirror/jupiter-main/os/x86_64/steamdeck-kde-presets-${version}-1-any.pkg.tar.zst";
    sha256 = "0mgdkcq9z4r9wlwl02ihrigg3hay5kn7475vqmqgs13nvpy22000"; # Update this when updating version using nix-prefetch-url
  };

  # Add zstd to nativeBuildInputs for extraction
  nativeBuildInputs = [ zstd ];

  unpackPhase = ''
    mkdir -p source
    tar --use-compress-program=unzstd -xf $src -C source
  '';

  installPhase = ''
    runHook preInstall
    
    # Remove unused configurations
    rm -rf source/etc

    # Create necessary directories
    mkdir -p $out/share/plasma/desktoptheme/Vapor
    mkdir -p $out/share/plasma/look-and-feel/Vapor
    mkdir -p $out/share/color-schemes
    mkdir -p $out/share/wallpapers
    mkdir -p $out/share/konsole
    mkdir -p $out/share/icons
    mkdir -p $out/share/themes
    mkdir -p $out/share/plasma/avatars

    # Copy resources from the source theme package
    [ -d source/usr/share/plasma/look-and-feel ] && cp -r source/usr/share/plasma/look-and-feel/* $out/share/plasma/look-and-feel/
    [ -d source/usr/share/plasma/desktoptheme ] && cp -r source/usr/share/plasma/desktoptheme/* $out/share/plasma/desktoptheme/
    [ -d source/usr/share/color-schemes ] && cp -r source/usr/share/color-schemes/* $out/share/color-schemes/
    [ -d source/usr/share/wallpapers ] && cp -r source/usr/share/wallpapers/* $out/share/wallpapers/
    [ -d source/usr/share/konsole ] && cp -r source/usr/share/konsole/* $out/share/konsole/
    [ -d source/usr/share/icons ] && cp -r source/usr/share/icons/* $out/share/icons/
    [ -d source/usr/share/themes ] && cp -r source/usr/share/themes/* $out/share/themes/
    [ -d source/usr/share/plasma/avatars ] && cp -r source/usr/share/plasma/avatars/* $out/share/plasma/avatars/
    
    runHook postInstall
  '';

  meta = with lib; {
    description = "Vapor - SteamOS Theme based on KDE Breeze and Breath";
    homepage = "https://github.com/TimoVerbrugghe/homelab-monorepo/";
    license = licenses.gpl3;
    platforms = platforms.all;
    maintainers = with maintainers; [ timoverbrugghe ];
  };
}