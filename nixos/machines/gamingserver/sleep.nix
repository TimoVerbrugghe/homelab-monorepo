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
  security.sudo.extraRules = [
    {
      users = [ "gamer" ];
      commands = [
        { command = "/run/current-system/sw/bin/systemctl suspend"; options = [ "NOPASSWD" ]; }
      ];
    }
  ];

}