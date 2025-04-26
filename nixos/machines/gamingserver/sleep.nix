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

  # Put system to sleep at 4 am if I would forget to put it to sleep myself
  systemd.services.scheduled-sleep = {
    description = "Put system to sleep";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.systemd}/bin/systemctl suspend";
    };
  };

  systemd.timers.scheduled-sleep = {
    description = "Timer to put system to sleep at 4 AM";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* 04:00:00";
      Persistent = false;  # Don't trigger missed executions (so that it doesn't trigger after sleep of several days)
      Unit = "scheduled-sleep.service";
    };
  };
}