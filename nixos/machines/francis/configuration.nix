# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ssh-keys, ... }:

let 

  hostname = "francis";
  username = "francis";
  hashedPassword = "$y$j9T$9Ek82Q9I2UVzBr5ltiXe81$ecbngo9YPvlENaM0gDRJH0P8dgB7X5RrbAbZKsD5Gs4";
  kernelParams = [
     "i915.enable_guc=2" # Enable Intel Quicksync
  ];
  
  # Load bochs (proxmox standard VGA driver) after the i915 driver so that we can use noVNC while iGPU was passed through
  extraModprobeConfig = ''
  softdep bochs pre: i915
  '';

in 

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../modules/default.nix # Add default modules
      ../../modules/portainer-server.nix # Enable Portainer Server at startup
      ../../modules/vm-options.nix # Some default options you should enable on VMs  
      ../../modules/vscode-server.nix # Enable VS Code server
      ../../modules/tailscale.nix # Common tailscale config options, you need to add a tailscale authkey file to /etc/nixos/tailscale-authkey    
      ../../modules/intel-gpu-drivers.nix # Install Intel GPU drivers
    ];

  ############################
  ## Host Specific Settings ##
  ############################
  networking.hostName = "${hostname}"; # Define your hostname.
  boot.kernelParams = kernelParams;
  boot.extraModprobeConfig = extraModprobeConfig;
  hardware.cpu.intel.updateMicrocode = true;

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
