{ config, pkgs, ... }:

{
  # Enable ZFS kernel modules & some settings
  boot.initrd.kernelModules = [ "zfs" ];
  services.zfs.autoScrub.enable = true;
  services.zfs.trim.enable = true;

  boot.kernelPackages = pkgs.zfs.latestCompatibleLinuxPackages; # Making sure we're running latest linux kernel that is ZFS compatible
}