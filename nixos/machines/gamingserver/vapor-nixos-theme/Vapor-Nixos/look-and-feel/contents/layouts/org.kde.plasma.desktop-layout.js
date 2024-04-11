loadTemplate("org.kde.plasma.desktop.defaultPanel")

var desktopsArray = desktopsForActivity(currentActivity());
for( var i = 0; i < desktopsArray.length; i++) {

    // Set default wallpaper
    desktopsArray[i].wallpaperPlugin = 'org.kde.image';
    desktopsArray[i].currentConfigGroup = new Array("Wallpaper", "org.kde.image", "General");
    desktopsArray[i].writeConfig("Image", "/run/current-system/sw/share/plasma/desktoptheme/Vapor-Nixos/wallpapers/Steam Deck Logo Default.jpg");

    // Set default application launcher icon
    desktopsArray[i].currentConfigGroup = ["General"];
    desktop.writeConfig("icon", "/run/current-system/sw/share/plasma/desktoptheme/Vapor-Nixos/icons/start.svg");
}