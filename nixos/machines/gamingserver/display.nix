{ config, pkgs, ... }:

{

  # Making sure amdgpu driver is loaded on boot otherwise blank screen after init
  boot.initrd.kernelModules = [
    "amdgpu"
  ];

  # Enable opengl and 32 bit driver support
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  # Basic config of wayland and desktop manager
  services.xserver = {
    enable = true;
    xkb.layout = "be";
    videoDrivers = ["amdgpu"];
    desktopManager.plasma5.enable = true;
  };

  services.displayManager = {
    defaultSession = "plasmawayland";
    autoLogin.enable = true;
    autoLogin.user = "gamer";
    sddm = {
      enable = true;
      wayland.enable = true;
      wayland.compositor = "kwin";
      theme = "VaporNixos";
      autoLogin.relogin = true;
    };
  };

  # Networkmanager is needed for integration with KDE Plasma
  networking.networkmanager.enable = true;

  # Install a custom version of the KDE theme that Valve ships on SteamDeck
  environment.systemPackages = with pkgs; [
    (pkgs.callPackage ./vapor-nixos-theme/package.nix {})
  ];

  # Set up default KDE5 Plasma settings by putting config files in /etc/xdg
  environment.etc = {

    # Notification settings
    "xdg/plasmanotifyrc" = {
      text = ''
        [Applications][@other]
        ShowPopups=false

        [Applications][org.kde.konsole]
        ShowBadges=false
        ShowInHistory=false
        ShowPopups=false

        [Applications][org.kde.spectacle]
        ShowBadges=false
        ShowInHistory=false
        ShowPopups=false

        [Badges]
        InTaskManager=false

        [Jobs]
        InNotifications=false
        InTaskManager=false

        [Notifications]
        CriticalInDndMode=false
        LowPriorityPopups=false

        [Services][kaccess]
        ShowInHistory=false
        ShowPopups=false

        [Services][plasma_workspace]
        ShowInHistory=false
        ShowPopups=false

        [Services][devicenotifications]
        ShowInHistory=false
        ShowPopups=false

        [Services][freespacenotifier]
        ShowInHistory=false
        ShowPopups=false

        [Services][kcm_touchpad]
        ShowInHistory=false
        ShowPopups=false

        [Services][ksmserver]
        ShowInHistory=false
        ShowPopups=false

        [Services][kwalletd5]
        ShowInHistory=false
        ShowPopups=false

        [Services][kwin]
        ShowInHistory=false
        ShowPopups=false

        [Services][kwrited]
        ShowInHistory=false
        ShowPopups=false

        [Services][networkmanagement]
        ShowInHistory=false
        ShowPopups=false

        [Services][org.kde.kded.inotify]
        ShowInHistory=false
        ShowPopups=false

        [Services][phonon]
        ShowInHistory=false
        ShowPopups=false

        [Services][policykit1-kde]
        ShowInHistory=false
        ShowPopups=false

        [Services][powerdevil]
        ShowInHistory=false
        ShowPopups=false

        [Services][printmanager]
        ShowInHistory=false
        ShowPopups=false

        [Services][proxyscout]
        ShowInHistory=false
        ShowPopups=false

        [Services][xdg-desktop-portal-kde]
        ShowInHistory=false
        ShowPopups=false
      '';
    };

    # Audio settings
    "xdg/plasmaparc" = {
      text = ''
        [General]
        DefaultOutputDeviceOsd=false
        MicrophoneSensitivityOsd=false
        MuteOsd=false
        VolumeOsd=false
      '';
    };

    # Desktop Session Settings
    "xdg/ksmserverrc" = {
      text = ''
        [General]
        confirmLogout=false
      '';
    };

    # Disable KDE Wallet
    "xdg/kwalletrc" = {
      text = ''
        [Wallet]
        Enabled=false
      '';
    };

    # Do not load several KDE modules
    "xdg/kded5rc" = {
      text = ''
        [Module-appmenu]
        autoload=false

        [Module-baloosearchmodule]
        autoload=false

        [Module-browserintegrationreminder]
        autoload=false

        [Module-colorcorrectlocationupdater]
        autoload=false

        [Module-device_automounter]
        autoload=false

        [Module-freespacenotifier]
        autoload=false

        [Module-gtkconfig]
        autoload=false

        [Module-inotify]
        autoload=false

        [Module-kded_touchpad]
        autoload=false

        [Module-keyboard]
        autoload=false

        [Module-khotkeys]
        autoload=false

        [Module-kscreen]
        autoload=false

        [Module-ksysguard]
        autoload=false

        [Module-ktimezoned]
        autoload=true

        [Module-networkmanagement]
        autoload=true

        [Module-networkstatus]
        autoload=true

        [Module-plasma_accentcolor_service]
        autoload=false

        [Module-printmanager]
        autoload=false

        [Module-proxyscout]
        autoload=false

        [Module-remotenotifier]
        autoload=false

        [Module-smbwatcher]
        autoload=true

        [Module-statusnotifierwatcher]
        autoload=false
      '';
    };

    # Disable KDE Search Indexing
    "xdg/baloofilerc" = {
      text = ''
        [Basic Settings]
        Indexing-Enabled=false
      '';
    };

    # Set AC Power Settings
    "xdg/powermanagementprofilesrc" = {
      text = ''
        [AC]
        icon=battery-charging

        [AC][DimDisplay]
        idleTime=300000

        [AC][HandleButtonEvents]
        lidAction=1
        powerButtonAction=1
        powerDownAction=16
      '';
    };

    # Set KDE Global Settings (f.e. theme and color scheme)
    "xdg/kdeglobals" = {
      text = ''
        [KDE]
        LookAndFeelPackage=VaporNixos
        SingleClick=false

        [KDE Action Restrictions][$i]
        action/switch_user=false
        action/start_new_session=false
        action/lock_screen=false
      
        [General]
        ColorScheme=VaporNixos
        font=Noto Sans,11,-1,5,50,0,0,0,0,0
        menuFont=Noto Sans,11,-1,5,50,0,0,0,0,0
        smallestReadableFont=Noto Sans,9,-1,5,50,0,0,0,0,0
        toolBarFont=Noto Sans,11,-1,5,50,0,0,0,0,0
      '';
    };

  };

}