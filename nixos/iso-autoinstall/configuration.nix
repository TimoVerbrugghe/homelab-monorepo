# A nix configuration for an autoinstaller ISO (to be used in a VM)

{ config, pkgs, ... }:

{
  imports = [
    # Import minimal ISO CD
    <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix>

    # Provide an initial copy of the NixOS channel so that the user
    # doesn't need to run "nix-channel --update" first.
    <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix>
  ];

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

  # Enable git & sgdisk for partitioning and installing from github flakes later
  environment.systemPackages = with pkgs; [
    nano
    git
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
      hashedPassword = "$y$j9T$C0wb1ID4TZ6AG28ZPpDJN.$hdlvhNBwHMiutJXOavXlGB38qz93yA3CzitJv/DVDx9";
      openssh.authorizedKeys.keyFiles = [ ssh-keys.outPath ];
    };
  };

  # ISO Image options
  isoImage.compressImage = false;
  isoImage.isoBaseName = "nixos-auto-installer";
  isoImage.isoName = "${config.isoImage.isoBaseName}-${config.system.nixos.label}-${pkgs.stdenv.hostPlatform.system}.iso";
  isoImage.makeEfiBootable = true;
  isoImage.makeUsbBootable = true;
  isoImage.volumeID = "NIXOS_ISO";
  isoImage.storeContents = [ installBuild.toplevel ];
  isoImage.includeSystemBuildDependencies = true; # unconfirmed if this is really needed

  systemd.services.installer = {
    description = "Unattended NixOS installer";
    wantedBy = [ "multi-user.target" ];
    after = [ "getty.target" "nscd.service" ];
    conflicts = [ "getty@tty1.service" ];
    serviceConfig = {
      Type="oneshot";
      RemainAfterExit="yes";
      StandardInput="tty-force";
      StandardOutput="inherit";
      StandardError="inherit";
      TTYReset="yes";
      TTYVHangup="yes";
    };
    path = [ "/run/current-system/sw" ];
    environment = config.nix.envVars // {
      inherit (config.environment.sessionVariables) NIX_PATH;
      HOME = "/root";
    };
    script = ''
      set -euxo pipefail

      # Wipe disk and create 3 partitions
      sgdisk --zap-all /dev/sda
      sgdisk --new=1:0:+512M --typecode=1:ef00 /dev/sda
      sgdisk --new=2:0:0 --typecode=2:8300 /dev/sda
      sgdisk --new=3:0:+4G --typecode=3:8200 /dev/sda

      echo "y" | mkfs.fat -F 32 -n boot /dev/sda1
      mkfs.btrfs -F -L nixos /dev/sda2
      mkswap -L /dev/sda3
      swapon /dev/sda3

      # Labels do not appear immediately, so wait a moment
      sleep 5

      # Mount partitions for installation
      mount /dev/disk/by-label/nixos /mnt
      mkdir -p /mnt/boot
      mount /dev/disk/by-label/boot /mnt/boot

      # Generate nixos configuration and hardware configuration
      nixos-generate-config --root /mnt

      # # nixos-install will run "nix build --store /mnt ..." which won't be able
      # # to see what we have in the installer nix store, so copy everything
      # # needed over.
      # nix build -f '<nixpkgs/nixos>' system -I "nixos-config=/mnt/etc/nixos/configuration.nix" -o /out
      # nix copy --no-check-sigs --to local?root=/mnt /out

      ${installBuild.nixos-install}/bin/nixos-install --no-root-passwd
      reboot
    '';
  };
}