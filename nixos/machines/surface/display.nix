{ config, pkgs, ... }:

{

  # Enable opengl and 32 bit driver support
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [
      vpl-gpu-rt
    ];
  };

  # Basic config of wayland and desktop manager
  services.xserver = {
    enable = true;
    xkb.layout = "be";
    videoDrivers = ["amdgpu"];
    desktopManager.plasma5.enable = true;
  };

  services.displayManager = {
    defaultSession = "plasmawayland";
    sddm = {
      enable = true;
      wayland.enable = true;
      wayland.compositor = "kwin";
    };
  };

  # Networkmanager is needed for integration with Gnome
  networking.networkmanager.enable = true;

}