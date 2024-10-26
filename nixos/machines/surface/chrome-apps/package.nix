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

    (makeDesktopItem {
      name = "Sonarr";
      desktopName = "Sonarr";
      exec = "google-chrome-stable --profile-directory=Default --app=\"https://sonarr.pony-godzilla.ts.net/\" %U";
      comment = "Launch Sonarr";
      genericName = "Launch Sonarr";
      categories = ["Utility"];
      icon = ./sonarr.svg;
      startupWMClass = "chrome-sonarr.pony-godzilla.ts.net__-Default";
    })

    (makeDesktopItem {
      name = "Radarr";
      desktopName = "Radarr";
      exec = "google-chrome-stable --profile-directory=Default --app=\"https://radarr.pony-godzilla.ts.net/\" %U";
      comment = "Launch Radarr";
      genericName = "Launch Radarr";
      categories = ["Utility"];
      icon = ./radarr.svg;
      startupWMClass = "chrome-radarr.pony-godzilla.ts.net__-Default";
    })
    
    (makeDesktopItem {
      name = "Overseerr";
      desktopName = "Overseerr";
      exec = "google-chrome-stable --profile-directory=Default --app=\"https://request.pony-godzilla.ts.net/\" %U";
      comment = "Launch Overseerr";
      genericName = "Launch Overseerr";
      categories = ["Utility"];
      icon = ./overseerr.svg;
      startupWMClass = "chrome-request.pony-godzilla.ts.net__-Default";
    })

    (makeDesktopItem {
      name = "Portainer";
      desktopName = "Portainer";
      exec = "google-chrome-stable --profile-directory=Default --app=\"https://portainer.timo.be/\" %U";
      comment = "Launch Portainer";
      genericName = "Launch Portainer";
      categories = ["Utility"];
      icon = ./portainer.svg;
      startupWMClass = "chrome-portainer.timo.be__-Default";
    })
    
    (makeDesktopItem {
      name = "WhatsApp";
      desktopName = "WhatsApp";
      exec = "google-chrome-stable --profile-directory=Default --app=\"https://web.whatsapp.com/\" %U";
      comment = "Launch WhatsApp";
      genericName = "Launch WhatsApp";
      categories = ["Utility"];
      icon = ./whatsapp.svg;
      startupWMClass = "chrome-web.whatsapp.com__-Default";
    })

    (makeDesktopItem {
      name = "Bring";
      desktopName = "Bring";
      exec = "google-chrome-stable --profile-directory=Default --app=\"https://web.getbring.com/\" %U";
      comment = "Launch Bring";
      genericName = "Launch Bring";
      categories = ["Utility"];
      icon = ./bring.svg;
      startupWMClass = "chrome-web.getbring.com__-Default";
    })

    (makeDesktopItem {
      name = "YouTube";
      desktopName = "YouTube";
      exec = "google-chrome-stable --profile-directory=Default --app=\"https://www.youtube.com/\" %U";
      comment = "Launch YouTube";
      genericName = "Launch YouTube";
      categories = ["Utility"];
      icon = ./youtube.svg;
      startupWMClass = "chrome-www.youtube.com__-Default";
    })

    (makeDesktopItem {
      name = "Home Assistant";
      desktopName = "Home Assistant";
      exec = "google-chrome-stable --profile-directory=Default --app=\"https://hass.timo.be/\" %U";
      comment = "Launch Home Assistant";
      genericName = "Launch Home Assistant";
      categories = ["Utility"];
      icon = ./hass.svg;
      startupWMClass = "chrome-hass.timo.be__-Default";
    })

    (makeDesktopItem {
      name = "iCloud Reminders";
      desktopName = "iCloud Reminders";
      exec = "google-chrome-stable --profile-directory=Default --app=\"https://www.icloud.com/reminders/\" %U";
      comment = "Launch iCloud Reminders";
      genericName = "Launch iCloud Reminders";
      categories = ["Utility"];
      icon = ./reminders.png;
      startupWMClass = "chrome-icloud.com__-Default";
    })

    (makeDesktopItem {
      name = "iCloud Photos";
      desktopName = "iCloud Photos";
      exec = "google-chrome-stable --profile-directory=Default --app=\"https://www.icloud.com/photos/\" %U";
      comment = "Launch iCloud Photos";
      genericName = "Launch iCloud Photos";
      categories = ["Utility"];
      icon = ./photos.svg;
      startupWMClass = "chrome-icloud.com__-Default";
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
