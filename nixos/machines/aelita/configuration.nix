# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ssh-keys, ... }:

let 

  hostname = "aelita";
  username = "aelita";
  hashedPassword = "$y$j9T$3CG7KE5qgfuBLRxsUIgN8/$DG1HbNtEa9VA.oM6ZFyCicO9uJOSwFl.nJo0HNbtIv5";
  kernelParams = [
  ];
  extraModprobeConfig = ''
  '';

in 

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../modules/default.nix # Add default modules
      ../../modules/portainer-agent.nix # Enable Portainer Server at startup
      ../../modules/vm-options.nix # Some default options you should enable on VMs      
    ];

  ############################
  ## Host Specific Settings ##
  ############################
  networking.hostName = "${hostname}"; # Define your hostname.
  boot.kernelParams = kernelParams;
  boot.extraModprobeConfig = extraModprobeConfig;
  hardware.cpu.amd.updateMicrocode = true;

  # Set up single user using user.nix module
  services.user = {
    user = "${username}";
    hashedPassword = "${hashedPassword}";
  };

  ## Enable AutoUpgrades using autoupgrade.nix module
  services.autoUpgrade = {
    hostname = "${hostname}";
  };

}
