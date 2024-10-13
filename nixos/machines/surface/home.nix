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
    "org/gnome" = {
      "shell" = {
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

      "desktop" = {
        "datetime" = {
          automatic-timezone = true;
        };
        "input-sources" = {
          mru-sources = [
            "xkb:us::eng"
            "xkb:be::bel"
          ];
          sources = [
            "xkb:us::eng"
            "xkb:be::bel"
          ];
          xkb-model = "pc105+inet";
        };
        "interface" = {
          clock-format = "24h";
          clock-show-date = true;
          clock-show-seconds = false;
          clock-show-weekday = true;
          color-scheme = "prefer-dark";
          enable-animations = true;
          enable-hot-corners = false;
          show-battery-percentage = true;
        };
        "peripherals/touchpad" = {
          click-method = "fingers";
          accel-profile = "default";
          disable-while-typing = true;
          edge-scrolling-enabled = false;
          natural-scroll = true;
          tap-to-click = true;
          two-finger-scrolling-enabled = true;
        }
      };

      # Enable fractional scaling on user level on top of system wide (just to be sure)
      "mutter" = {
        "experimental-features" = [
          "scale-monitor-framebuffer"
        ];
      };

      "settings-daemon" = {
        "plugins" = {
          "power" = {
            power-button-action = "suspend";
            power-saver-profile-on-low-battery = true;
            sleep-inactive-ac-timeout = 900;
            sleep-inactive-ac-type = "suspend";
            sleep-inactive-battery-timeout = 900;
            sleep-inactive-battery-type = "suspend";
          };
        };
      };

      "shell/extensions" = {
        "just-perfection" = {
          clock-menu-position=0;
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

        "blur-my-shell" = {
          pipelines = "{'pipeline_default': {'name': <'Default'>, 'effects': <[<{'type': <'native_static_gaussian_blur'>, 'id': <'effect_000000000000'>, 'params': <{'radius': <30>, 'brightness': <0.59999999999999998>}>}>]>}, 'pipeline_default_rounded': {'name': <'Default rounded'>, 'effects': <[<{'type': <'native_static_gaussian_blur'>, 'id': <'effect_000000000001'>, 'params': <{'radius': <30>, 'brightness': <0.59999999999999998>}>}>, <{'type': <'corner'>, 'id': <'effect_000000000002'>, 'params': <{'radius': <30>, 'corners_top': <true>, 'corners_bottom': <true>}>}>]>}}";
          settings-version = 2;
          "appfolder" = {
            blur = true;
            brightness = 0.59999999999999998;
            sigma = 30;
          };
          "applications" = {
            blur = true;
            whitelist = [
              "org.gnome.Nautilus"
              "org.gnome.Console"
              "org.gnome.Calculator"
            ];
          };
          "dash-to-dock" = {
            blur=true;
            brightness=0.59999999999999998;
            override-background=true;
            pipeline="pipeline_default_rounded";
            sigma=30;
            static-blur=true;
            style-dash-to-dock=0;
            unblur-in-overview=false;
          };
          "dash-to-panel" = {
            blur-original-panel = true;
          };
          "lockscreen" = {
            pipeline = "pipeline_default";
          };
          "overview" = {
            blur = true;
            pipeline = "pipeline_default";
            style-components=0;
          };
          "panel" = {
            brightness=0.59999999999999998;
            force-light-text=true;
            override-background=true;
            override-background-dynamically=false;
            pipeline="pipeline_default";
            sigma=30;
            static-blur=true;
            style-panel=0;
          };
          "screenshot" = {
            pipeline = "pipeline_default";
          };
          "window-list" = {
            brightness=0.59999999999999998;
            sigma=30;
          };
        };

        "dash-to-dock" = {
          always-center-icons=false;
          apply-custom-theme=true;
          autohide=true;
          autohide-in-fullscreen=true;
          background-color="rgb(255,255,255)";
          background-opacity=0.80000000000000004;
          click-action="focus-minimize-or-previews";
          custom-background-color=false;
          custom-theme-shrink=true;
          dash-max-icon-size=48;
          disable-overview-on-startup=true;
          dock-fixed=false;
          dock-position="BOTTOM";
          extend-height=false;
          height-fraction=0.90000000000000002;
          icon-size-fixed=true;
          intellihide=true;
          intellihide-mode="MAXIMIZED_WINDOWS";
          middle-click-action="launch";
          preferred-monitor=-2;
          preferred-monitor-by-connector="Virtual-1";
          preview-size-scale=0.29999999999999999;
          running-indicator-style="DOTS";
          shift-click-action="minimize";
          shift-middle-click-action="launch";
          show-apps-at-top=true;
          show-mounts-network=true;
          transparency-mode="DYNAMIC";
        };
      };
    };
  };
};