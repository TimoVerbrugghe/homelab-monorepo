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
}