# A nix configuration for an autoinstaller ISO (to be used in a VM)

{ config, pkgs, ... }:

{
  # Enable git & sgdisk for partitioning and installing from github flakes later
  environment.systemPackages = with pkgs; [
    nano
    git
    gptfdisk
  ];

  # ISO Image options
  isoImage.squashfsCompression = "gzip -Xcompression-level 1";
  isoImage.isoBaseName = "nixos-auto-installer";
  isoImage.isoName = "${config.isoImage.isoBaseName}-${config.system.nixos.label}-${pkgs.stdenv.hostPlatform.system}.iso";
  isoImage.makeEfiBootable = true;
  isoImage.makeUsbBootable = true;
  isoImage.volumeID = "NIXOS_ISO";


  # When generating the nixos-config for the system, use the install-configuration.nix file
  system.nixos-generate-config.configuration = builtins.readFile ./install-configuration;

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

      # Format the 3 partitions with specific labels
      echo "y" | mkfs.fat -F 32 -n boot /dev/sda1
      mkfs.btrfs -F -L nixos /dev/sda2
      mkswap -L swap /dev/sda3
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

      nixos-install --no-root-passwd
      reboot
    '';
  };
}

