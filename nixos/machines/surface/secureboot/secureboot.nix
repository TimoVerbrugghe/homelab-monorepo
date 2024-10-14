{ config, lib, pkgs, lanzaboote, ... }:

{
  environment.systemPackages = [
    # For debugging and troubleshooting Secure Boot.
    pkgs.sbctl
    pkgs.efibootmgr
  ];

  # Lanzaboote currently replaces the systemd-boot module.
  # This setting is usually set to true in configuration.nix
  # generated at installation time. So we force it to false
  # for now.
  # boot.loader.systemd-boot.enable = lib.mkForce false;

  # boot.lanzaboote = {
  #  enable = true;
  #  pkiBundle = "/etc/secureboot";
  # };

  environment.etc."secureboot" = {
    PreLoader.efi = {
      source = ./PreLoader.efi;
      mode = "0644";
    };
    HashTool.efi = {
      source = ./HashTool.efi;
      mode = "0644";
    };
  };
}
