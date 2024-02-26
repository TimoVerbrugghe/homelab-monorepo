# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ssh-keys, ... }:

let 

  hostname = "nixos";
  username = "nixos";
  hashedPassword = "$y$j9T$C0wb1ID4TZ6AG28ZPpDJN.$hdlvhNBwHMiutJXOavXlGB38qz93yA3CzitJv/DVDx9";
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

  ## Networking setup

  networking = {
    usePredictableInterfaceNames = false;
    defaultGateway = "10.10.10.1";
    interfaces = {
      eth0 = {
        ipv4.addresses  = [
          { address = "10.10.10.23"; prefixLength = 24; }
        ];
      };
			macvlan0 = {
				ipv4.adresses =  [ 
					{ address = "10.10.10.0"; prefixLength = 24; } 
				];
				ipv4.routes = [
					{ address = "10.10.10.22"; }
				];
			};
    };

		macvlans.macvlan0 = {
			interface = "eth0";
			mode = "bridge";
		};


  };
}
