{ config, pkgs, ... }:

{

  environment.etc."plasmanotifyrc" = {
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
    '';
  };

}