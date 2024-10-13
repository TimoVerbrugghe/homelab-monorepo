{ config, pkgs, ... }:

{
  imports = [
    # Intel GPU drivers
    ../../modules/intel-gpu-drivers.nix
  ];

  # Enable opengl and 32 bit driver support
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [
      onevpl-intel-gpu
      # vpl-gpu-rt after 24.11
    ];
  };

  # Enable belgian keyboard & format options
  services.xserver = {
    enable = true;
    xkb.layout = "be";
  };

  console.keyMap = "be-latin1";

  i18n.supportedLocales = [ 
    "en_US.UTF-8" 
    "nl_BE.UTF-8" 
  ];
}