{ config, pkgs, ... }:

{
  # Enable ZFS kernel modules & some settings
  boot.initrd.kernelModules = [ "zfs" ];
  services.zfs.autoScrub.enable = true;
  services.zfs.trim.enable = true;
  boot.supportedFilesystems = [ "zfs" ];

  # Set networking.hostId because ZFS needs this to prevent zfs pool from being mounted on the wrong machine. Host id is derived from the systemd machine id (head -c 8 /etc/machine-id)
  networking.hostId = "e6b5d6a5";

  boot.kernelPackages = pkgs.zfs.latestCompatibleLinuxPackages; # Making sure we're running latest linux kernel that is ZFS compatible

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

  services.sanoid = {
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
}