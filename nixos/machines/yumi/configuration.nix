# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ssh-keys, ... }:

let 

  hostname = "yumi";
  username = "yumi";
  hashedPassword = "$y$j9T$Mh0gtGs5dzw.7oMTrWrmV.$7QTuj6tpMnkTmlVGzas/vEh9sdUzezyiv4CS.f8M6I2";
  ipAddress = "10.10.10.7";
  kernelParams = [
     "i915.enable_guc=3" # Enable Intel Quicksync
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
      ../../modules/common.nix # Add default modules
      ../../modules/portainer-server.nix # Enable Portainer Server at startup
      ../../modules/vm-options.nix # Some default options you should enable on VMs      
      ../../modules/vscode-server.nix # Enable VS Code server
      ../../modules/tailscale.nix # Common tailscale config options, you need to add a tailscale authkey file to /etc/nixos/tailscale-authkey
      ../../modules/intel-gpu-drivers.nix # Install Intel GPU drivers
      ../../modules/acme.nix # Get certs using nixos's built-in acme function (which uses lego), you need to add a cloudflare api key file to /etc/nixos/cloudflare-apikey.nix
      ../../modules/check-disk-usage.nix # Notify if disk usage is above 80%
    ];

  networking.firewall.enable = false;

  ############################
  ## Host Specific Settings ##
  ############################
  networking.hostName = "${hostname}"; # Define your hostname.
  boot.kernelParams = kernelParams;
  boot.extraModprobeConfig = extraModprobeConfig;
  hardware.cpu.intel.updateMicrocode = true;
  console.keyMap = "be-latin1";

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

		macvlans = {
      macvlan0 = {
			  interface = "eth0";
			  mode = "bridge";
		  };
    };

    usePredictableInterfaceNames = false;
    defaultGateway = "${config.vars.defaultGateway}";
    interfaces = {
      eth0 = {
        ipv4.addresses  = [
          { address = "${ipAddress}"; prefixLength = 24; }
        ];
      };
			
      macvlan0 = {
				ipv4.addresses =  [ 
					{ address = "10.10.10.0"; prefixLength = 24; } 
				];
				ipv4.routes = [
					{ address = "10.10.10.20"; prefixLength = 32; }
          { address = "10.10.10.28"; prefixLength = 32; }
          { address = "10.10.10.29"; prefixLength = 32; }
				];
			};
    };

    # Open firewall again for cloudflared-tunnel
    firewall.allowedTCPPorts = [ 443 ];

  };

}
