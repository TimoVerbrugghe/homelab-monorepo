{
  lib,
  appimageTools,
  fetchurl,
}:

let
  version = "1.1.1401";
  pname = "Ryujinx";
  name = "${pname}-${version}";
  src = /etc/nixos/ryujinx.AppImage;
  appimageContents = appimageTools.extractType2 { inherit pname version src; };

in

appimageTools.wrapType2 {
  inherit pname version src;

  # No need to mv $out/bin/${name} $out/bin/${pname} since appimageTools.extractType2 already uses pname for the executable
  # Not all appimages have icons in /usr/share/icons, so we use cp -r ... || true to ignore errors
  extraInstallCommands = ''
    install -m 444 -D ${appimageContents}/${pname}.desktop -t $out/share/applications
    substituteInPlace $out/share/applications/${pname}.desktop \
      --replace-fail 'Exec=' 'Exec=${pname}'
    cp -r ${appimageContents}/usr/share/icons $out/share || true
  '';

  meta = with lib; {
    homepage = "https://ryujinx.org/";
    changelog = "https://github.com/Ryujinx/Ryujinx/wiki/Changelog";
    description = "Experimental Nintendo Switch Emulator written in C#";
    longDescription = ''
      Ryujinx is an open-source Nintendo Switch emulator, created by gdkchan,
      written in C#. This emulator aims at providing excellent accuracy and
      performance, a user-friendly interface and consistent builds. It was
      written from scratch and development on the project began in September
      2017.
    '';
    license = licenses.mit;
    maintainers = with maintainers; [ jk artemist ];
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    mainProgram = "Ryujinx";
  };
}