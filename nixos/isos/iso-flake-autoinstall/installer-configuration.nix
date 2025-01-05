# A nix configuration for an autoinstaller ISO (to be used in a VM)

{ config, pkgs, nixpkgs, ... }:

let
  
  # Change this with the name of the flake in this github repo you want to autoinstall
  flake = "aelita";

in

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
    package = pkgs.nixVersions.stable;
    extraOptions = ''
        experimental-features = nix-command flakes
    '';
  };

  # ISO Image options
  isoImage.squashfsCompression = "gzip -Xcompression-level 1";
  isoImage.isoBaseName = "nixos-flake-auto-installer";
  isoImage.isoName = "${config.isoImage.isoBaseName}-${config.system.nixos.label}-${pkgs.stdenv.hostPlatform.system}.iso";
  isoImage.makeEfiBootable = true;
  isoImage.makeUsbBootable = true;
  isoImage.volumeID = "NIXOS_ISO";

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
      if [ -e "/dev/sda" ]; then
        DEVICE="/dev/sda"
      # Check if /dev/vda is available
      elif [ -e "/dev/vda" ]; then
        DEVICE="/dev/vda"
      else
        echo "Error: No suitable disk found (/dev/sda or /dev/vda)."
        exit 1
      fi

      # Check if both /dev/sda and /dev/vda are available
      if [ -e "/dev/sda" ] && [ -e "/dev/vda" ]; then
        echo "Both /dev/sda and /dev/vda has been found. The auto installer doesn't support this."
        echo "Shutting down the machine in 10 seconds."
        sleep 10
        shutdown -h now
      fi

      # Wipe disk and create 3 partitions
      sgdisk --zap-all "''${DEVICE}"
      sgdisk --new=1:0:+512M --typecode=1:ef00 "''${DEVICE}"
      sgdisk --new=2:0:+4G --typecode=2:8200 "''${DEVICE}"
      sgdisk --new=3:0:0 --typecode=3:8300 "''${DEVICE}"

      # Format the 3 partitions with specific labels
      echo "y" | mkfs.fat -F 32 -n BOOT "''${DEVICE}1"
      mkswap -L swap "''${DEVICE}2"
      swapon "''${DEVICE}2"
      mkfs.xfs -f -L nixos "''${DEVICE}3"

      # Labels do not appear immediately, so wait a moment
      sleep 5

      # Mount partitions for installation
      mount "/dev/disk/by-label/nixos" /mnt
      mkdir -p /mnt/boot
      mount "/dev/disk/by-label/BOOT" /mnt/boot

      nixos-install --no-root-passwd --impure --no-write-lock-file -v --show-trace --root /mnt --flake github:TimoVerbrugghe/homelab-monorepo?dir=nixos#${flake}
      echo "Installation succeeded. Will shutdown machine in 5 seconds"
      sleep 5
      shutdown -h now
    '';
  };
}

