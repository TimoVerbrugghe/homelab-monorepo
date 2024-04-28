{ config, pkgs, ... }:

{
  ## Boot Configuration
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 3;

  # Making sure we're running latest linux kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Reduce swappiness
  boot.kernel.sysctl = { "vm.swappiness" = 20;};

  # Add ability to mount nfs shares
  environment.systemPackages = with pkgs; [ nfs-utils ];
  boot.initrd = {
    supportedFilesystems = [ "nfs" ];
    kernelModules = [ "nfs" ];
  };

  # Clean /tmp folder on reboot (apparantly false by default)
  boot.tmp.cleanOnBoot = true;
}