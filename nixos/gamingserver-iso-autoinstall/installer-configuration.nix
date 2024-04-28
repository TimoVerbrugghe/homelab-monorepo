# A nix configuration for an autoinstaller ISO (to be used in a VM)

{ config, pkgs, nixpkgs, ... }:

{
  imports =
    [ 
      # Import minimal ISO CD
      (nixpkgs + /nixos/modules/installer/cd-dvd/installation-cd-minimal.nix)

      # Import tools (needed for certain options such as system.nixos-generate-config)
      (nixpkgs + /nixos/modules/installer/tools/tools.nix)

        # Provide an initial copy of the NixOS channel so that the user
      # doesn't need to run "nix-channel --update" first.
      (nixpkgs + /nixos/modules/installer/cd-dvd/channel.nix)
    ];

  # Enable git & sgdisk for partitioning and installing from github flakes later
  environment.systemPackages = with pkgs; [
    nano
    git
    gptfdisk
  ];

  # Making sure DNS works
  networking.nameservers = [
    "1.1.1.1"
    "8.8.8.8"
    "8.8.4.4"
  ];

  ## Enable Flakes
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
        experimental-features = nix-command flakes
    '';
  };

  # ISO Image options
  isoImage.squashfsCompression = "gzip -Xcompression-level 1";
  isoImage.isoBaseName = "nixos-auto-installer";
  isoImage.isoName = "${config.isoImage.isoBaseName}-${config.system.nixos.label}-${pkgs.stdenv.hostPlatform.system}.iso";
  isoImage.makeEfiBootable = true;
  isoImage.makeUsbBootable = true;
  isoImage.volumeID = "NIXOS_ISO";

  # When generating the nixos-config for the system, use the install-configuration.nix file
  system.nixos-generate-config.configuration = builtins.readFile ./install-configuration.nix;

  systemd.services.installer = {
    description = "Unattended NixOS installer";
    wantedBy = [ "multi-user.target" ];
    after = [ "getty.target" "nscd.service" "network-online.target" ];
    wants = [ "getty.target" "nscd.service" "network-online.target" ];
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

      # Check if /dev/sda is available
      if [ -e "/dev/nvme0n1"]; then
        DEVICE="/dev/nvme0n1"
      else
        echo "Error: No NVME drive (/dev/nvme0n1) found and you're not gonna game on a sata ssd right?"
        exit 1
      fi

      # Wipe disk and create 3 partitions
      sgdisk --zap-all "''${DEVICE}"
      sgdisk --new=1:0:+512M --typecode=1:ef00 "''${DEVICE}"
      sgdisk --new=2:0:+4G --typecode=2:8200 "''${DEVICE}"
      sgdisk --new=3:0:0 --typecode=3:8300 "''${DEVICE}"

      # Format the 3 partitions with specific labels
      echo "y" | mkfs.fat -F 32 -n BOOT "''${DEVICE}p1"
      mkswap -L swap "''${DEVICE}p2"
      swapon "''${DEVICE}p2"
      zpool create -O compression=on -O mountpoint=none -O xattr=sa -O acltype=posixacl -o ashift=12 zpool /dev/nvme0n1p3

      zfs create -o mountpoint=legacy zpool/root
      zfs create -o mountpoint=legacy zpool/nix
      zfs create -o mountpoint=legacy zpool/home
      
      mount -t zfs zpool/root /mnt
      mkdir -p /mnt/nix /mnt/home

      mount -t zfs zpool/nix /mnt/nix
      mount -t zfs zpool/home /mnt/home

      # Labels do not appear immediately, so wait a moment
      sleep 5

      # Mount partitions for installation
      mkdir -p /mnt/boot
      mount "/dev/disk/by-label/BOOT" /mnt/boot

      # Generate nixos configuration and hardware configuration
      nixos-generate-config --root /mnt

      # Retrieve the host ID using head -c 8 /etc/machine-id because ZFS needs this to prevent zfs pool from being mounted on the wrong machine. Host id is derived from the systemd machine id
      # Insert the networking.hostId line before the last closing curly brace in configuration.nix
      sed -i '/^}$/i networking.hostId = "'$(head -c 8 /etc/machine-id)'";' /mnt/etc/nixos/configuration.nix

      nixos-install --no-root-passwd
      echo "Installation succeeded. Will shutdown machine in 5 seconds"
      sleep 5
      shutdown -h now

    '';
  };
}

