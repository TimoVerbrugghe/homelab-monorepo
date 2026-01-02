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
    dialog
    nfs-utils
  ];

  # Add ability to mount nfs shares
  boot.initrd = {
    supportedFilesystems = [ "nfs" ];
    kernelModules = [ "nfs" ];
  };

  # Making sure DNS works
  networking.nameservers = [
    "1.1.1.1"
    "8.8.8.8"
    "8.8.4.4"
  ];

  ## Enable Flakes & unfree packages
  nix = {
    package = pkgs.nixVersions.stable;
    extraOptions = ''
        experimental-features = nix-command flakes
    '';
  };
  nixpkgs.config.allowUnfree = true;

  # Console, layout options
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "be-latin1";
  time.timeZone = "Europe/Brussels";

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  users.users = {
    root = {
      password = "root";

      # Add public key for TheFactory TrueNAS so that TrueNAS can send zfs snapshots using a replication task
      openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC2BZgvsUxnbuSWfVaL7aP9UPGHIkc4SRwiwTU0uXVY35v8wBCfVmeHj552IjcluQy7JReQCmLDm6lepWPWjMagr9aw/CaXLJ/cvMHcAqaPDdVkuBX9M0xEq60isr9yj9gUq+FZW/8c1WAbaAVzD2M2PzZG19JPmvqrljWD90YTpRZbM5vWXYenVXj97t8OaRGnXrkENYfyIb2SxPLcbtou1W9IE6jLiNpsW8vqZgcPWwBfG4BJ06xwrgdrSjIsjBwVia9spHBnk3uz/F5/ziQvQRZfqDsXFAUX2V3VD0LNg4Vx3SAbN8cQYZraFnZHsyzxFPCdJsYroVsMFmhZN0Z1V0k54X+wp/DnUs4lU36jGIWEHW3ibvHD+BETUwb2OrRWNZLhmFTFeuk/J11nb8zCJwPkRuO1tH87KZQSZFLT3l1oCzEXx1UQecIxr+0uSk9N64OSV0+NjosAXc4kt2YmlV2P93wM4uadpUliZZXNM/EBoBDCS0jABAX12wniTq0= root@TheFactory"];
    };
  };

  # ISO Image options
  isoImage.squashfsCompression = "gzip -Xcompression-level 1";
  isoImage.isoBaseName = lib.mkForce "nixos-gamingserver-installer";
  isoImage.isoName = lib.mkForce "${config.isoImage.isoBaseName}-${config.system.nixos.label}-${pkgs.stdenv.hostPlatform.system}.iso";
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

      # Clear terminal to start with clean screen
      clear

      # Warning user installation will begin
      dialog --backtitle "Gaming Server NixOS installation" --msgbox "Starting installation of NixOS based Gaming Server. This installation requires existing snapshots of gamingpool/root and gamingpool/home to be restored. Press enter to start." 30 50
      clear

      ## NVME DEVICE CHECK
      echo "Checking if NVME device is available"

      # Check if an nvme device is available
      if [ -e "/dev/nvme0n1" ]; then
        echo "NVME drive found, continuing installation"
      else
        echo "Error: No NVME drive (/dev/nvme0n1) found. Cancelling installation."
        exit 1
      fi

      ## NVME DEVICE SELECTION
      # Get list of NVMe devices and their sizes in bytes
      mapfile -t devices < <(lsblk -b -d -o NAME,SIZE -e 7,11 | grep nvme)

      # Initialize variables
      largest_size=0
      largest_device=""

      # Loop through devices and their sizes
      for i in "''${devices[@]}"; do
        name=$(echo "$i" | awk '{print $1}')
        size=$(echo "$i" | awk '{print $2}')

        # Check if this device is the largest so far
        if [ "$size" -gt "$largest_size" ]; then
          largest_size=$size
          largest_device="/dev/$name"
        fi
      done

      DEVICE=$largest_device

      ## WIPING DISKS
      # Wipe disk and create 3 partitions
      echo "Wiping installation medium and creating partitions"

      sgdisk --zap-all "''${DEVICE}"

      # Boot partition
      echo "Creating boot partition"
      sgdisk --new=1:0:+512M --typecode=1:ef00 "''${DEVICE}"

      # Swap partition
      echo "creating swap partition"
      sgdisk --new=2:0:+4G --typecode=2:8200 "''${DEVICE}"

      # ZFS partition
      echo "creating ZFS partition"
      sgdisk --new=3:0:0 --typecode=3:bf00 "''${DEVICE}"

      # Format the 3 partitions with specific labels
      echo "Formatting partitions"
      echo "y" | mkfs.fat -F 32 -n BOOT "''${DEVICE}p1"
      mkswap -L swap "''${DEVICE}p2"
      swapon "''${DEVICE}p2"

      echo "Creating ZFS gamingpool"
      # Using -f option to override existing pools
      zpool create -O compression=on -O mountpoint=none -O xattr=sa -O acltype=posixacl -o ashift=12 -f gamingpool "''${DEVICE}p3"

      zfs create -o mountpoint=legacy gamingpool/root
      zfs create -o mountpoint=legacy gamingpool/nix
      zfs create -o mountpoint=legacy gamingpool/home
      
      # Showing message to user to restore zfs snapshots to gamingpool
      dialog --backtitle "ZFS Restore of gaming server" --msgbox "Please restore zfs snapshots to gamingpool/root and gamingpool/home. IP address of this system: $(ifconfig | grep 'inet ' | awk '{ print $2 }' | head -n 1). Once snapshot restore is complete, press enter." 10 40
      clear

      # Mount partitions for installation
      echo "setting mountpoint to legacy and Mounting drives"
      zfs set mountpoint=legacy gamingpool/root
      zfs set mountpoint=legacy gamingpool/nix
      zfs set mountpoint=legacy gamingpool/home

      mount -t zfs gamingpool/root /mnt
      mkdir -p /mnt/nix /mnt/home

      mount -t zfs gamingpool/nix /mnt/nix
      mount -t zfs gamingpool/home /mnt/home

      # Labels do not appear immediately, so wait a moment
      sleep 5
      
      mkdir -p /mnt/boot
      mount "/dev/disk/by-label/BOOT" /mnt/boot

      ## Tailscale Setup
      # Checking if zfs snapshot restore has restored a tailscale authkey file, if yes, copy it to /etc directory (from /mnt/etc)
      if [ -e "/mnt/etc/nixos/tailscale-authkey.nix" ]; then
        mkdir -p /etc/nixos
        cp /mnt/etc/nixos/tailscale-authkey.nix /etc/nixos/tailscale-authkey.nix
      else
        # Notifying user that he has to manually transfer a /mnt/etc/nixos/tailscale-authkey.nix file
        dialog --backtitle "Tailscale Setup" --msgbox "A tailscale-authkey nix file is required for this installation and was NOT found in the zfs snapshot restore. Please ssh with username and password root to this system (IP: $(ifconfig | grep 'inet ' | awk '{ print $2 }' | head -n 1)) and transfer it to /etc/nixos/tailscale-authkey.nix" 12 60
      fi

      ## Citra source setup
      # Checking if zfs snapshot restore has restored a citra source file, if yes, copy it to /etc directory (from /mnt/etc)
      if [ -e "/mnt/etc/nixos/citra-unified-source.tar.xz" ]; then
        mkdir -p /etc/nixos
        cp /mnt/etc/nixos/citra-unified-source.tar.xz /etc/nixos/citra-unified-source.tar.xz
      else
        # Notifying user that he has to manually transfer a /mnt/etc/nixos/citra-unified-source.tar.xz file
        dialog --backtitle "Citra Setup" --msgbox "A citra source file is required for this installation and was NOT found in the zfs snapshot restore. Please ssh with username and password root to this system (IP: $(ifconfig | grep 'inet ' | awk '{ print $2 }' | head -n 1)) and transfer it to /etc/nixos/citra-unified-source.tar.xz" 12 60
      fi

      dialog --backtitle "Starting Installation" --title "Warning" --msgbox "FINAL WARNING: NixOS Installation will now begin" 10 40
      clear

      echo "Starting Installation"
      nixos-install --no-root-passwd --impure --no-write-lock-file -v --show-trace --root /mnt --flake github:TimoVerbrugghe/homelab-monorepo?dir=nixos#gamingserver
      echo "Installation succeeded. Will umount all drives, export pools and then shutdown machine in 5 seconds"

      # Making sure any caches are flushed and installation has done everything it needed to do so that I can "safely" unmount drives
      sleep 20

      ## Home Manager Fixes
      # Home Manager restored from a zfs snapshot and then installed as new has an issues where previous generation number & paths are in conflict.
      # If you don't mind losing previous profile generations (and I don't on a restore) then the easiest solutions is by removing certain folders mentioned below
      rm -rf /mnt/home/gamer/.local/state/nix/profiles/home-manager*
      rm -rf /mnt/home/gamer/.local/state/home-manager/gcroots/current-home

      ## Unmounting drives
      umount /mnt/nix
      umount /mnt/home

      # I have to force unmount here and I really don't know why, lsof doesn't show anything so...???
      umount -l /mnt

      # exporting pools
      zpool export gamingpool

      dialog --backtitle "Installation Complete" --title "Post-Installation Instructions" --msgbox "Installation is complete. When restarting into the system, don't forget to test out truenas zfs backups (might need to rediscover host key of SSH target)" 12 50
      clear
      
      sleep 5
      shutdown -h now

    '';
  };
}

