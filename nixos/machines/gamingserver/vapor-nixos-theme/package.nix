{ stdenv, lib }:

let
  themeName = "Vapor-Nixos";
  fs = lib.fileset;
  sourceFiles = ./Vapor-Nixos;
in
stdenv.mkDerivation rec {
  pname = "vapor-nixos-theme";
  version = "1.0.0";

  src = fs.toSource {
    root = ./.;
    fileset = sourceFiles;
  };

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/plasma/desktoptheme/${themeName}
    mkdir -p $out/share/plasma/look-and-feel/${themeName}
    cp -a $src/${themeName}/desktoptheme/. $out/share/plasma/desktoptheme/${themeName}
    cp -a $src/${themeName}/look-and-feel/. $out/share/plasma/look-and-feel/${themeName}
    runHook postInstall
  '';

  meta = with lib; {
    description = "A customized version of the Vapor theme from Valve used on SteamOS to use on Nixos";
    homepage = "https://github.com/TimoVerbrugghe/homelab-monorepo/";
    license = licenses.gpl3;
    platforms = platforms.all;
    maintainers = with maintainers; [ timoverbrugghe ];
  };
}