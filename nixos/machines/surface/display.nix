{ config, pkgs, ... }:

{
  imports = [
    # Intel GPU drivers
    ../../modules/intel-gpu-drivers.nix
  ];

  # Enable opengl support
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      vpl-gpu-rt
    ];
  };

  # Enable belgian keyboard & format options
  services.xserver = {
    enable = true;
    xkb.layout = "be";
  };

  console.keyMap = "be-latin1";

  i18n.supportedLocales = [ 
    "en_US.UTF-8/UTF-8" 
    "nl_BE.UTF-8/UTF-8" 
  ];
}