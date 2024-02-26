# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ssh-keys, ... }:

let 

  hostname = "francis";
  username = "francis";
  hashedPassword = "$y$j9T$zfgP2dDLwZElN/J4eKMcB/$sOQIFZXnBGJXf752bG/hqgmj4hIq3KOW8nGpqQIiR9.";
  ipAddress = "192.168.0.2";
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

  ## Passthrough hostname for tailscale
  services.tailscale = {
    hostname = "${hostname}";
  };

  ## Networking setup

  networking = {

    usePredictableInterfaceNames = false;
    defaultGateway = "192.168.0.1";
    interfaces = {
      eth0 = {
        ipv4.addresses  = [
          { address = "${ipAddress}"; prefixLength = 24; }
        ];
      };
    };


  };

}
