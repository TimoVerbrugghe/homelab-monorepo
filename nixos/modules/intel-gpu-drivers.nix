{ config, pkgs, ... }:

{
  # Necessary to install GPU drivers
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    clinfo
    libva-utils
    intel-gpu-tools
  ];

  # Install Intel GPU Drivers
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-compute-runtime
      vaapiVdpau
      libvdpau-va-gl
      vaapiIntel
      intel-ocl
    ];
  };
}