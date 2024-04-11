{ config, pkgs, ... }:

{

  # Making sure amdgpu driver is loaded on boot otherwise blank screen after init
  boot.initrd.kernelModules = [
    "amdgpu"
  ];

  # Enable opengl and 32 bit driver support
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  # Basic config of wayland and desktop manager
  services.xserver = {
    enable = true;
    xkb.layout = "be";
    videoDrivers = ["amdgpu"];
    desktopManager.plasma5.enable = true;
    displayManager = {
      defaultSession = "plasmawayland";
      autoLogin.enable = true;
      autoLogin.user = "gamer";
      sddm = {
        enable = true;
        wayland.enable = true;
        wayland.compositor = "kwin";
      };
    };
  };

  # Networkmanager is needed for integration with KDE Plasma
  networking.networkmanager.enable = true;

}