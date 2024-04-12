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
      autoLogin.relogin = true;
      sddm = {
        enable = true;
        wayland.enable = true;
        wayland.compositor = "kwin";
        theme = "Vapor-Nixos";
      };
    };
  };

  # Networkmanager is needed for integration with KDE Plasma
  networking.networkmanager.enable = true;

  # Install a custom version of the KDE theme that Valve ships on SteamDeck
  ## TO-DO: Automatic configuration of plasma theme management - Find a way to make this theme the default
  # Create a systemd service that executes plasma-apply-lookandfeel -a Vapor-Nixos --resetLayout to apply the theme and all of its look-and-feel settings

  environment.systemPackages = with pkgs; [
    (pkgs.callPackage ./vapor-nixos-theme/package.nix {})
  ];

}