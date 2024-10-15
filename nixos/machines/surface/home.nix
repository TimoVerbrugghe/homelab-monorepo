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

    "org/gnome/shell/desktop/datetime" = {
        automatic-timezone = true;
    };
    "org/gnome/shell/desktop/input-sources" = {
      mru-sources = [
        "xkb"
        "be"
      ];
      sources = [
        "xkb"
        "be"
      ];
      xkb-model = "pc105+inet";
    };
    "org/gnome/shell/desktop/interface" = {
      clock-format = "24h";
      clock-show-date = true;
      clock-show-seconds = false;
      clock-show-weekday = true;
      color-scheme = "prefer-dark";
      enable-animations = true;
      enable-hot-corners = false;
      show-battery-percentage = true;
    };
    "org/gnome/shell/desktop/peripherals/touchpad" = {
      click-method = "fingers";
      accel-profile = "default";
      disable-while-typing = true;
      edge-scrolling-enabled = false;
      natural-scroll = true;
      tap-to-click = true;
      two-finger-scrolling-enabled = true;
    };

      # Enable fractional scaling on user level on top of system wide (just to be sure)
    "org/gnome/mutter" = {
      "experimental-features" = [
        "scale-monitor-framebuffer"
      ];
    };

    "org/gnome/settings-daemon/plugins/power" = {
      power-button-action = "suspend";
      power-saver-profile-on-low-battery = true;
      sleep-inactive-ac-timeout = 900;
      sleep-inactive-ac-type = "suspend";
      sleep-inactive-battery-timeout = 900;
      sleep-inactive-battery-type = "suspend";
    };

    "org/gnome/shell/extensions/just-perfection" = {
      clock-menu-position=0;
      clock-menu-position-offset=0;
      controls-manager-spacing-size=0;
      notification-banner-position=2;
      osd-position=5;
      panel-button-padding-size=11;
      panel-indicator-padding-size=11;
      search=true;
      startup-status=0;
      theme=false;
      workspaces-in-app-grid=true;
    };

    "org/gnome/shell/extensions/blur-my-shell" = {
      pipelines = "{'pipeline_default': {'name': <'Default'>, 'effects': <[<{'type': <'native_static_gaussian_blur'>, 'id': <'effect_000000000000'>, 'params': <{'radius': <30>, 'brightness': <0.59999999999999998>}>}>]>}, 'pipeline_default_rounded': {'name': <'Default rounded'>, 'effects': <[<{'type': <'native_static_gaussian_blur'>, 'id': <'effect_000000000001'>, 'params': <{'radius': <30>, 'brightness': <0.59999999999999998>}>}>, <{'type': <'corner'>, 'id': <'effect_000000000002'>, 'params': <{'radius': <30>, 'corners_top': <true>, 'corners_bottom': <true>}>}>]>}}";
      settings-version = 2;
    };
    "org/gnome/shell/extensions/blur-my-shell/appfolder" = {
      blur = true;
      brightness = 0.59999999999999998;
      sigma = 30;
      style-dialogs=1;
    };
    "org/gnome/shell/extensions/blur-my-shell/applications" = {
      blur = true;
      whitelist = [
        "org.gnome.Nautilus"
        "org.gnome.Console"
        "org.gnome.Calculator"
      ];
    };
    "org/gnome/shell/extensions/blur-my-shell/dash-to-dock" = {
      blur=false;
    };
    "org/gnome/shell/extensions/blur-my-shell/dash-to-panel" = {
      blur-original-panel = true;
    };
    "org/gnome/shell/extensions/blur-my-shell/lockscreen" = {
      pipeline = "pipeline_default";
    };
    "org/gnome/shell/extensions/blur-my-shell/overview" = {
      blur = true;
      pipeline = "pipeline_default";
      style-components=3;
    };
    "org/gnome/shell/extensions/blur-my-shell/panel" = {
      brightness=0.59999999999999998;
      force-light-text=true;
      override-background=true;
      override-background-dynamically=false;
      pipeline="pipeline_default";
      sigma=30;
      static-blur=true;
      style-panel=0;
    };
    "org/gnome/shell/extensions/blur-my-shell/screenshot" = {
      pipeline = "pipeline_default";
    };
    "org/gnome/shell/extensions/blur-my-shell/window-list" = {
      brightness=0.59999999999999998;
      sigma=30;
    };

    "org/gnome/shell/extensions/dash-to-dock" = {
      always-center-icons=false;
      apply-custom-theme=false;
      autohide=true;
      autohide-in-fullscreen=true;
      background-color="rgb(255,255,255)";
      background-opacity=0.20000000000000000;
      click-action="focus-minimize-or-previews";
      custom-background-color=true;
      custom-theme-shrink=true;
      dash-max-icon-size=48;
      disable-overview-on-startup=true;
      dock-fixed=false;
      dock-position="BOTTOM";
      extend-height=false;
      height-fraction=0.90000000000000000;
      icon-size-fixed=false;
      intellihide=true;
      intellihide-mode="ALL_WINDOWS";
      max-alpha=0.80000000000000000;
      middle-click-action="launch";
      multi-monitor=true;
      preview-size-scale=0.29999999999999999;
      require-pressure-to-show=false;
      running-indicator-style="DOTS";
      shift-click-action="minimize";
      shift-middle-click-action="launch";
      show-apps-at-top=true;
      show-dock-urgent-notify=true;
      show-mounts=true;
      show-mounts-network=false;
      show-trash=false;
      transparency-mode="FIXED";
    };
  };
}