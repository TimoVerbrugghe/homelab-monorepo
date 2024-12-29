{ config, pkgs, ... }:

{
  # Enable ZFS kernel modules & some settings
  boot.initrd.kernelModules = [ "zfs" ];
  services.zfs.autoScrub.enable = true;
  services.zfs.trim.enable = true;
  boot.supportedFilesystems = [ "zfs" ];

  # Set networking.hostId because ZFS needs this to prevent zfs pool from being mounted on the wrong machine. Host id is derived from the systemd machine id (head -c 8 /etc/machine-id)
  networking.hostId = "e6b5d6a5";

  # Mount filesystems
  fileSystems."/" =
    { device = "gamingpool/root";
      fsType = "zfs";
    };

  fileSystems."/home" =
    { device = "gamingpool/home";
      fsType = "zfs";
    };

  fileSystems."/nix" =
    { device = "gamingpool/nix";
      fsType = "zfs";
    };

  services = {
    # Enable ZFS auto snapshotting locally
    sanoid = {
      enable = true;
      templates.backup = {
        hourly = 24;
        daily = 14;
        monthly = 3;
        autoprune = true;
        autosnap = true;
      };

      datasets."gamingpool/home" = {
        useTemplate = [ "backup" ];
      };

      datasets."gamingpool/root" = {
        useTemplate = [ "backup" ];
      };
    };

    # Send ZFS snapshots automatically to TrueNAS
    syncoid = {
      enable = true;
      commonArgs = [
        "--no-sync-snap"
      ];

      # Need to make sure that you run a manual syncoid command first AS USER SYNCOID because then it will place a .ssh folder in /var/lib/syncoid with known hosts, otherwise the systemd service will always fail
      sshKey = "/var/lib/syncoid/truenas-ssh-key";
      commands = {
        "gamingpool/home" = {
          source = "gamingpool/home";
          target = "root@truenas.local.timo.be:X.A.N.A./gamingserver-backup/home";
        };
        "gamingpool/root" = {
          source = "gamingpool/root";
          target = "root@truenas.local.timo.be:X.A.N.A./gamingserver-backup/root";
        };
      };
    };
  };
}