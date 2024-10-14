{ config, lib, pkgs, lanzaboote, ... }:

let

  preLoaderPath = "/etc/secureboot/PreLoader.efi";
  hashToolPath = "/etc/secureboot/HashTool.efi";
  systemdDir = "/boot/EFI/systemd";
  systemdBootPath = "/boot/EFI/systemd/systemd-bootx64.efi";
  loaderPath = "/boot/EFI/systemd/loader.efi";
  disk = "/dev/nvme0n1";  # Set your disk path here
  part = "1"; # Set your EFI partition number here

in

{
  environment.systemPackages = [
    # For debugging and troubleshooting Secure Boot.
    pkgs.sbctl
    pkgs.efibootmgr
  ];

  ########### Lanzaboote not yet supported on Surface devices ###########
  # Lanzaboote currently replaces the systemd-boot module.
  # This setting is usually set to true in configuration.nix
  # generated at installation time. So we force it to false
  # for now.
  # boot.loader.systemd-boot.enable = lib.mkForce false;

  # boot.lanzaboote = {
  #  enable = true;
  #  pkiBundle = "/etc/secureboot";
  # };

  # Placing PreLoader.efi and HashTool.efi in /etc/secureboot
  environment.etc = {
    "secureboot/PreLoader.efi" = {
      source = ./PreLoader.efi;
      mode = "0644";
    };
    "secureboot/HashTool.efi" = {
      source = ./HashTool.efi;
      mode = "0644";
    };
  };

  system.activationScripts.securebootEnable.text = ''
    #!/bin/sh

    echo "Creating systemd directory if it doesn't exist"
    if [ ! -d "${systemdDir}" ]; then
      mkdir -p ${systemdDir}
    fi

    echo "Copying PreLoader.efi if it doesn't exist"
    if [ ! -f "${systemdDir}/PreLoader.efi" ]; then
      cp ${preLoaderPath} ${systemdDir}/PreLoader.efi
    fi

    echo "Copying HashTool.efi if it doesn't exist"
    if [ ! -f "${systemdDir}/HashTool.efi" ]; then
      cp ${hashToolPath} ${systemdDir}/HashTool.efi
    fi

    # Copy systemd-bootx64.efi to loader.efi if newer
    if [ ${systemdBootPath} -nt ${loaderPath} ]; then
      cp ${systemdBootPath} ${loaderPath}
      echo "systemd-bootx64.efi is newer than loader.efi. Please readd it using HashTool on the next boot."
    fi

    echo "Creating NVRAM entry if it doesn't exist"
    if ! efibootmgr | grep -q "PreLoader"; then
      efibootmgr --unicode --disk ${disk} --part ${part} --create --label "PreLoader" --loader /EFI/systemd/PreLoader.efi
    fi

    echo "Making PreLoader the default boot option, and adding Linux/Windows Boot Managers if they exist"
    bootnum=$(efibootmgr | grep -i "PreLoader" | grep -oP 'Boot\K\d+')
    linux_boot=$(efibootmgr | grep -i "Linux Boot Manager" | grep -oP 'Boot\K\d+')
    windows_boot=$(efibootmgr | grep -i "Windows Boot Manager" | grep -oP 'Boot\K\d+')

    boot_order="''${bootnum}"
    if [ -n "$linux_boot" ]; then
      boot_order="''${boot_order},''${linux_boot}"
    fi
    if [ -n "$windows_boot" ]; then
      boot_order="''${boot_order},''${windows_boot}"
    fi

    efibootmgr -o ''${boot_order}

    echo "Comparing current and built initrd"
    booted=$(readlink /run/booted-system/initrd)
    built=$(readlink /nix/var/nix/profiles/system/initrd)

    if [ "''${built}" -nt "''${booted}" ]; then
      echo "A newer initrd is built. Please readd initrd using HashTool on the next boot."
    fi
  '';

  # The firmware will start Windows Boot Manager directly when selecting Windows 11, leaving the TPM PCRs in expected states so that Windows can unseal the encryption key.
  boot.loader.systemd-boot.rebootForBitlocker = true;
  
}
