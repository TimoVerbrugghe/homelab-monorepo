{ config, pkgs, ... }:

{

  # Bluetooth
  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot

  # AX200 Bluetooth module
  boot.kernelModules = [ "btintel" ];

  # Joycon & Switch Pro Controller support
  # services.joycond.enable = true;

  # services.udev.extraRules = ''
  #   KERNEL=="hidraw*", KERNELS=="*057E:2009*", TAG+="uaccess"
  # '';

}