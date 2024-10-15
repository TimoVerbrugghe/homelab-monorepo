{ stdenv, lib, makeDesktopItem, ...}:

stdenv.mkDerivation {
  pname = "chrome-apps";
  version = "1.0.0";

  dontUnpack = true;
  dontBuild = true;
  dontConfigure = true;

  desktopItems = [
    (makeDesktopItem {
      name = "Copilot";
      desktopName = "Copilot";
      exec = "google-chrome-stable --profile-directory=Default --app=\"https://copilot.microsoft.com/\" %U";
      comment = "Launch Microsoft Copilot";
      genericName = "Launch Microsoft Copilot";
      categories = ["Utility"];
      icon = ./copilot.svg;
      startupWMClass = "chrome-copilot.microsoft.com__-Default";
    })

    (makeDesktopItem {
      name = "Outlook";
      desktopName = "Outlook";
      exec = "google-chrome-stable --profile-directory=Default --app=\"https://outlook.com/\" %U";
      comment = "Launch Microsoft Outlook";
      genericName = "Launch Microsoft Outlook";
      categories = ["Utility"];
      icon = ./outlook.svg;
      startupWMClass = "chrome-outlook.com__-Default";
    })
  ];

  installPhase = ''
    runHook PreInstall

    if [ -z "$desktopItems" ]; then
        return
    fi

    mkdir -p $out/share/applications

    applications="$out/share/applications"
    for desktopItem in $desktopItems; do
        if [[ -f "$desktopItem" ]]; then
            echo "Copying '$desktopItem' into ''${applications}"
            install -D -m 444 -t ''${applications} "$desktopItem"
        else
            for f in "$desktopItem"/share/applications/*.desktop; do
                echo "Copying '$f' into ''${applications}"
                install -D -m 444 -t ''${applications} "$f"
            done
        fi
    done
    runHook PostInstall  
  '';

  meta = with lib; {
    description = "Several websites installed as chrome applications";
    license = licenses.mit;
    maintainers = with maintainers; [ timoverbrugghe ];
  };
}
