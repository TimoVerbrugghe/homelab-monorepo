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
        Exec="${pkgs.google-chrome}/bin/google-chrome-stable --app="https://copilot.microsoft.com/" %U
        Terminal=false
      '';
    };
  };
}