{ stdenv, lib, makeDesktopItem, copyDesktopItems, ...}:

stdenv.mkDerivation {
  pname = "chrome-apps";
  version = "1.0.0";

  dontConfigure = true;
  dontUnpack = true;

  nativeBuildInputs = [ copyDesktopItems ];

  desktopItems = [
    (makeDesktopItem {
      name = "Copilot";
      desktopName = "Copilot";
      exec = "/run/current-system/sw/bin/google-chrome-stable --profile-directory=Default --app=\"https://copilot.microsoft.com/\" %U";
      comment = "Launch Microsoft Copilot";
      genericName = "Launch Microsoft Copilot";
      categories = ["Utility"];
      icon = ./copilot.svg;
    })

    (makeDesktopItem {
      name = "Outlook";
      desktopName = "Outlook";
      exec = "/run/current-system/sw/bin/google-chrome-stable --profile-directory=Default --app=\"https://outlook.com/\" %U";
      comment = "Launch Microsoft Outlook";
      genericName = "Launch Microsoft Outlook";
      categories = ["Utility"];
      icon = ./outlook.svg;
    })
  ];

  buildPhase = ''
    echo "Building chrome apps"
  '';

  installPhase = ''
    runHook PreInstall
    mkdir -p $out/share/applications
    runHook PostInstall  
  '';

  meta = with lib; {
    description = "Several websites installed as chrome applications";
    license = licenses.mit;
    maintainers = with maintainers; [ timoverbrugghe ];
  };
}
