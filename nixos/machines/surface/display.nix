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

  # Basic config of wayland and desktop manager
  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };

}