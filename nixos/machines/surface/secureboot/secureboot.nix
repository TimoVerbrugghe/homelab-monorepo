{ config, lib, pkgs, lanzaboote, ... }:

let

  preLoaderPath = "/etc/secureboot/PreLoader.efi";
  hashToolPath = "/etc/secureboot/HashTool.efi";
  secureBootDir = "/boot/EFI/secureboot";
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

    # Create /boot/secureboot directory if it doesn't exist
    if [ ! -d "${secureBootDir}" ]; then
      mkdir -p ${secureBootDir}
    fi

    # Copy PreLoader.efi if it doesn't exist
    if [ ! -f "${secureBootDir}/PreLoader.efi" ]; then
      cp ${preLoaderPath} ${secureBootDir}/PreLoader.efi
    fi

    # Copy HashTool.efi if it doesn't exist
    if [ ! -f "${secureBootDir}/HashTool.efi" ]; then
      cp ${hashToolPath} ${secureBootDir}/HashTool.efi
    fi

    # Copy systemd-bootx64.efi to loader.efi if newer
    if [ ${systemdBootPath} -nt ${loaderPath} ]; then
      cp ${systemdBootPath} ${loaderPath}
    fi

    # Create NVRAM entry if it doesn't exist
    if ! ${pkgs.efibootmgr}/bin/efibootmgr | grep -q "PreLoader"; then
      ${pkgs.efibootmgr}/bin/efibootmgr --unicode --disk ${disk} --part ${part} --create --label "PreLoader" --loader /EFI/secureboot/PreLoader.efi
    fi

    # Make PreLoader the default boot option
    bootnum=$(${pkgs.efibootmgr}/bin/efibootmgr | grep -i "PreLoader" | grep -oP 'Boot\K\d+')
    if [ -n "$bootnum" ]; then
      ${pkgs.efibootmgr}/bin/efibootmgr -o $bootnum
    fi
  '';

  # The firmware will then start Windows Boot Manager directly, leaving the TPM PCRs in expected states so that Windows can unseal the encryption key.
  boot.loader.systemd-boot.rebootForBitlocker = true;
}
