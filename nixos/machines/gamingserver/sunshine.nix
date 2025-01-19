{ config, pkgs, ... }:

{
  # Uinput has to be loaded as a kernel module in order for sunshine to emulate controller
  boot.kernelModules = [
    "uinput"
  ];

  services.sunshine = {
    enable = true;
    capSysAdmin = true;
    openFirewall = true;
    autoStart = true;
  };

  # Needed for autodetection of sunshine in moonlight
  services.avahi.publish.enable = true;
  services.avahi.publish.userServices = true;
}