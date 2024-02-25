{ config, lib, pkgs, ssh-keys, ... }:

{
  # Bootloader options
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest; # Making sure we're running latest linux kernel
    
	# Allow firmware even with license
	hardware.enableRedistributableFirmware = true;
	hardware.enableAllFirmware = true;

  # Filesystem setup
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "btrfs";
  };

  fileSystems."/boot" ={ 
    device = "/dev/disk/by-label/BOOT";
    fsType = "vfat";
  };

  swapDevices =[ 
    { device = "/dev/disk/by-label/swap"; }
  ];

  # Console, layout options
  i18n.defaultLocale = "nl_BE.UTF-8";
  console.keyMap = "nl-be";
  time.timeZone = "Europe/Brussels";

  # Making sure DNS works
  networking.nameservers = [
    "1.1.1.1"
    "8.8.8.8"
    "8.8.4.4"
  ];

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # configure proprietary drivers
  nixpkgs.config.allowUnfree = true;

  ## Enable Flakes
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
        experimental-features = nix-command flakes
    '';
  };

  environment.systemPackages = with pkgs; [
    git
    nano
  ];

  # Enable QEMU guest agent for better VM integration
  services.qemuGuest.enable = true;

  # Create user that can be used after install
  users.mutableUsers = false;
  users.users = {

    nixos = {
      extraGroups = [ "wheel" ];
      isNormalUser = true;
      password = "nixos";
      openssh.authorizedKeys.keyFiles = [ ssh-keys.outPath ];
    };

  };
}