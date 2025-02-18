{ config, pkgs, ... }:

{
  ## Sleep setup - see for more info https://www.freedesktop.org/software/systemd/man/latest/sleep.conf.d.html
  systemd.sleep.extraConfig = ''
    AllowSuspend=yes
    AllowHibernation=yes
    AllowHybridSleep=yes
    AllowSuspendThenHibernate=yes
    HibernateDelaySec=3600
  '';

  # Allow the standard user (gamer) to suspend the system, necessary for home assistant ssh command to work without having to elevate privileges
  # This will allow the user to perform SUDO systemctl suspend without a password (just doing regular systemctl suspend without sudo will still prompt for a password through polkit)
  security.sudo.extraRules = [
    {
      users = [ "gamer" ];
      commands = [
        { command = "/run/current-system/sw/bin/systemctl suspend"; options = [ "NOPASSWD" ]; }
      ];
    }
  ];

  # # Autosleep at 3 am (if I forget to put the computer manually to sleep)
  # systemd.services.sleepAtFour = {
  #   description = "Put the machine to sleep at 4 am";
  #   wantedBy = [ "timers.target" ];
  #   serviceConfig = {
  #     Type = "oneshot";
  #     ExecStart = "${pkgs.systemd}/bin/systemctl suspend";
  #   };
  # };

  # systemd.timers.sleepAtFourTimer = {
  #   description = "Timer to put the machine to sleep at 4 am";
  #   wantedBy = [ "timers.target" ];
  #   timerConfig = {
  #     OnCalendar = "*-*-* 04:00:00";
  #     Persistent = true;  # Ensure the timer isn't missed if the machine was asleep at the scheduled time
  #   };
  # };
}