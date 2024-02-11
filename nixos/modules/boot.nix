{ config, pkgs, ... }:

{
  ## Boot Configuration
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 10;

  # Making sure we're running latest linux kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;  
}