{ stdenv, lib, fetchurl, zstd }:

let

  themeName = "Vapor";
  version = "0.28";

in

stdenv.mkDerivation rec {
  pname = "plasma6-vapor-nixos-theme";
  inherit version;
  
  src = fetchurl {
    url = "https://steamdeck-packages.steamos.cloud/archlinux-mirror/jupiter-main/os/x86_64/steamdeck-kde-presets-${version}-1-any.pkg.tar.zst";
    sha256 = "0mgdkcq9z4r9wlwl02ihrigg3hay5kn7475vqmqgs13nvpy22000"; # Update this if needed for 0.28
  };

  dontBuild = true;

  # Add zstd to nativeBuildInputs for extraction
  nativeBuildInputs = [ zstd ];

  unpackPhase = ''
    mkdir -p source
    tar --use-compress-program=unzstd -xf $src -C source
  '';

  installPhase = ''
    runHook preInstall
    
    # Remove unused configurations
    rm -rf source/etc/xdg

    # Create necessary directories
    mkdir -p $out/share/plasma/desktoptheme/${themeName}
    mkdir -p $out/share/plasma/look-and-feel/${themeName}
    mkdir -p $out/share/color-schemes
    mkdir -p $out/share/wallpapers
    mkdir -p $out/share/konsole
    mkdir -p $out/share/icons
    mkdir -p $out/share/themes
    mkdir -p $out/share/plasma/avatars

    # Copy and modify desktop theme
    cp -r source/usr/share/plasma/desktoptheme/Vapor/* $out/share/plasma/desktoptheme/${themeName}/
    
    # Update theme for Plasma 6
    # sed -i 's/X-Plasma-API=5.0/X-Plasma-API=6.0/g' $out/share/plasma/desktoptheme/${themeName}/metadata.desktop
    # sed -i "s/Name=Vapor/Name=${themeName}/g" $out/share/plasma/desktoptheme/${themeName}/metadata.desktop
    # sed -i "s/X-KDE-PluginInfo-Name=Vapor/X-KDE-PluginInfo-Name=${themeName}/g" $out/share/plasma/desktoptheme/${themeName}/metadata.desktop
    # sed -i "s/Comment=.*/Comment=VaporNixos - SteamOS Theme from Valve for Plasma 6 modified to be installed on NixOS/g" $out/share/plasma/desktoptheme/${themeName}/metadata.desktop
    
    # Setup look-and-feel component
    cp -r source/usr/share/plasma/look-and-feel/com.valve.vapor.desktop/* $out/share/plasma/look-and-feel/${themeName}/
    
    # # Update look-and-feel metadata for Plasma 6
    # if [ -f $out/share/plasma/look-and-feel/${themeName}/metadata.json ]; then
    #   sed -i "s/\"Id\": \"com.valve.vapor.desktop\"/\"Id\": \"${themeName}\"/g" $out/share/plasma/look-and-feel/${themeName}/metadata.json
    #   sed -i "s/\"Name\": \"Vapor\"/\"Name\": \"${themeName}\"/g" $out/share/plasma/look-and-feel/${themeName}/metadata.json
    #   sed -i 's/"X-Plasma-API": "5.0"/"X-Plasma-API": "6.0"/g' $out/share/plasma/look-and-feel/${themeName}/metadata.json
    # fi
    
    # if [ -f $out/share/plasma/look-and-feel/${themeName}/metadata.desktop ]; then
    #   sed -i "s/Name=Vapor/Name=${themeName}/g" $out/share/plasma/look-and-feel/${themeName}/metadata.desktop
    #   sed -i "s/X-KDE-PluginInfo-Name=com.valve.vapor.desktop/X-KDE-PluginInfo-Name=${themeName}/g" $out/share/plasma/look-and-feel/${themeName}/metadata.desktop
    #   sed -i 's/X-Plasma-API=5.0/X-Plasma-API=6.0/g' $out/share/plasma/look-and-feel/${themeName}/metadata.desktop
    # fi
    
    # Copy color schemes
    if [ -f $out/share/plasma/desktoptheme/${themeName}/colors ]; then
      cp $out/share/plasma/desktoptheme/${themeName}/colors $out/share/color-schemes/${themeName}.colors
    elif [ -f source/usr/share/color-schemes/Vapor.colors ]; then
      cp source/usr/share/color-schemes/Vapor.colors $out/share/color-schemes/${themeName}.colors
      sed -i "s/Vapor/${themeName}/g" $out/share/color-schemes/${themeName}.colors
    fi
    
    # Copy additional resources from the source package
    [ -d source/usr/share/wallpapers ] && cp -r source/usr/share/wallpapers/* $out/share/wallpapers/
    [ -d source/usr/share/konsole ] && cp -r source/usr/share/konsole/* $out/share/konsole/
    [ -d source/usr/share/icons/hicolor ] && cp -r source/usr/share/icons/hicolor $out/share/icons/
    [ -d source/usr/share/themes/Vapor ] && cp -r source/usr/share/themes/Vapor $out/share/themes/
    [ -d source/usr/share/plasma/avatars ] && cp -r source/usr/share/plasma/avatars/* $out/share/plasma/avatars/
    
    runHook postInstall
  '';

  meta = with lib; {
    description = "A customized version of the Vapor theme from Valve used on SteamOS to use on NixOS with Plasma 6";
    homepage = "https://github.com/TimoVerbrugghe/homelab-monorepo/";
    license = licenses.gpl3;
    platforms = platforms.all;
    maintainers = with maintainers; [ timoverbrugghe ];
  };
}