{
  lib,
  appimageTools,
  fetchurl,
}:

let
  version = "2088";
  pname = "citra-qt";
  name = "${pname}-${version}";
  src = /etc/nixos/citra-qt.AppImage;
  appimageContents = appimageTools.extractType2 { inherit pname version src; };

in

appimageTools.wrapType2 {
  inherit pname version src;

  # No need to mv $out/bin/${name} $out/bin/${pname} since appimageTools.extractType2 already uses pname for the executable

  extraInstallCommands = ''
    install -m 444 -D ${appimageContents}/${pname}.desktop -t $out/share/applications
    substituteInPlace $out/share/applications/${pname}.desktop \
      --replace-fail 'Exec=AppRun' 'Exec=${pname}'
    cp -r ${appimageContents}/usr/share/icons $out/share
  '';

  meta = with lib; {
    description = "The nightly branch of an open-source emulator for the Nintendo 3DS";
    longDescription = ''
      A Nintendo 3DS Emulator written in C++
      Using the nightly branch is recommended for general usage.
      Using the canary branch is recommended if you would like to try out
      experimental features, with a cost of stability.
    '';
    platforms = platforms.linux;
    license = licenses.gpl2Plus;
  };
}