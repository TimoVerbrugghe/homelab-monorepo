{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "timo";
  home.homeDirectory = "/home/timo";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Apparently this is required for home manager
  home.stateVersion = "24.05";

  home.file = {
    ## Check: https://discourse.nixos.org/t/module-to-manage-desktop-shortcuts-in-chromium-or-brave/47162

    # Input Remapper autoload desktop file placed in autostart so that it autostarts on login
    ".local/share/applications/copilot.desktop" = {
      text = ''
        [Desktop Entry]
        Type=Application
        Name=Copilot
        Comment=Launch Microsoft Copilot
        Exec=${pkgs.google-chrome}/bin/google-chrome-stable --app="https://copilot.microsoft.com/" %U
        Terminal=false
      '';
    };
  };

  dconf.settings = {
    # Gnome settings
    "org/gnome/shell" = {
      disable-user-extensions = false;
      disabled-extensions = [
      ];
      enabled-extensions = [
        "dash-to-dock@micxgx.gmail.com"
        "windowgestures@extension.amarullz.com" 
        "custom-window-controls@icedman.github.com"
        "blur-my-shell@aunetx" 
        "just-perfection-desktop@just-perfection"
        "caffeine@patapon.info"
      ];

      # Apps to show in the dock
      favorite-apps = [
        "org.gnome.Nautilus.desktop"
        "google-chrome.desktop"
        "code.desktop"
        "spotify.desktop"
        "bitwarden.desktop"
        "org.gnome.Console.desktop"
        "org.gnome.Settings.desktop"
      ];
    };

    "org/gnome/shell/extensions/just-perfection" = {
      clock-menu-position=1;
      clock-menu-position-offset=0;
      controls-manager-spacing-size=0;
      notification-banner-position=2;
      osd-position=8;
      panel-button-padding-size=11;
      panel-indicator-padding-size=11;
      search=true;
      startup-status=0;
      theme=false;
      workspaces-in-app-grid=false;
    };
  };
}