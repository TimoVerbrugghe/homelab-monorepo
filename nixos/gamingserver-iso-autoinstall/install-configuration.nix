{ config, lib, pkgs, ... }:

{
  # Bootloader options
  boot.initrd.availableKernelModules = [ "ata_piix" "xhci_pci" "uhci_hcd" "ehci_pci" "ahci" "virtio_pci" "virtio_scsi" "virtio_blk" "sd_mod" "sr_mod" ];
  boot.supportedFilesystems = [ "btrfs" "vfat" ];
  boot.kernelModules = [ "kvm-intel" "kvm-amd" ];
  boot.initrd.kernelModules = [ "zfs" ];
  services.zfs.autoScrub.enable = true;
  services.zfs.trim.enable = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.zfs.latestCompatibleLinuxPackages; # Making sure we're running latest linux kernel that is ZFS compatible
    
	# Allow firmware even with license
	hardware.enableRedistributableFirmware = true;
	hardware.enableAllFirmware = true;

  # Filesystem setup
  fileSystems."/" =
    { device = "zpool/root";
      fsType = "zfs";
    };

  fileSystems."/nix" =
    { device = "zpool/nix";
      fsType = "zfs";
    };

  fileSystems."/home" =
    { device = "zpool/home";
      fsType = "zfs";
    };

  swapDevices =[ 
    { device = "/dev/disk/by-label/swap"; }
  ];

  # Console, layout options
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "be-latin1";
  time.timeZone = "Europe/Brussels";

  # Networking setup
  networking.useDHCP = lib.mkDefault true;
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
    gptfdisk
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
    };

  };
}