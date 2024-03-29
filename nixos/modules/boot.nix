{ config, pkgs, ... }:

{
  ## Boot Configuration
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 3;

  # Making sure we're running latest linux kernel
  # Temporarily moving to kernel 6.7 due to bug in intel-compute-runtime which doesn't work with kernel 6.8, see https://github.com/intel/compute-runtime/issues/710
  boot.kernelPackages = pkgs.linuxPackages_6_7;

  # Reduce swappiness
  boot.kernel.sysctl = { "vm.swappiness" = 20;};

  # Add ability to mount nfs shares
  environment.systemPackages = with pkgs; [ nfs-utils ];
  boot.initrd = {
    supportedFilesystems = [ "nfs" ];
    kernelModules = [ "nfs" ];
  };
}