{ config, lib, pkgs, ... }:

{
  # Dock

  system.defaults = {
    dock = {
      autohide = true;
      magnification = true;
      orientation = "bottom";
      show-recents = false;
    };

    finder ={
      # Do not show icons on the desktop
      CreateDesktop = false;

      # Do not show warning when changing extensions of files
      FXEnableExtensionChangeWarning = false;

      # Standard view style in Finder windows is column view
      FXPreferredViewStyle = "clmv";

      # Autodelete trash items after 30 days
      FXRemoveOldTrashItems = true;

      ShowExternalHardDrivesOnDesktop = true;
      ShowHardDrivesOnDesktop = false;
      ShowMountedServersOnDesktop = false;
      ShowRemovableMediaOnDesktop = true;
    };

    loginwindow = {
      GuestEnabled = false;
    };

    magicmouse = {
      # Enable right click
      MouseButtonMode = "TwoButton";
    };

    menuExtraClock = {
      Show24Hour = true;
      # 0 = When space allows 1 = Always 2 = Never
      ShowDate = 0;
      ShowDayOfWeek = true;
      ShowDayOfMonth = true;
    };

    screencapture = {
      target = "clipboard";
    };

    trackpad = {
      # Enable tap to click
      Clicking = true;
      TrackpadRightClick = true;
    };

    SoftwareUpdate = {
      AutomaticallyInstallMacOSUpdates = true;
    };

    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      AppleMeasurementUnits = "Centimeters";
      AppleTemperatureUnit = "Celsius";
    };

    controlcenter = {
      BatteryShowPercentage = true;
    };
  };

  # By default, this option does not affect your system configuration in any way. However, this means that after it has been set once, unsetting it will not return to the old behavior. It will allow the setting to be controlled in System Settings, though.
  system.startup.chime = true;

  # Add ability to used TouchID for sudo authentication
  security.pam.services.sudo_local.touchIdAuth = true;
}