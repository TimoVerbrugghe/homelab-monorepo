# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ssh-keys, ... }:

let 

  hostname = "k3stest";
  username = "k3stest";
  hashedPassword = "$y$j9T$G8vT64n6w00cGuLAkDvYY1$I/plAezB1079RyiGDfs8P.UjBHnBT6LmwdMuzEw3364";
  ipAddress = "10.10.10.12";
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
      ../../modules/vm-options.nix # Some default options you should enable on VMs      
      ../../modules/tailscale.nix # Common tailscale config options, you need to add a tailscale authkey file to /etc/nixos/tailscale-authkey
      ../../modules/intel-gpu-drivers.nix # Install Intel GPU drivers
      ../../modules/check-disk-usage.nix # Notify if disk usage is above 80%
    
      ## KUBERNETES SETUP ##
      ../../modules/k3s/k3s-common.nix
      ../../modules/k3s/k3s-server.nix
      ../../modules/k3s/kube-vip.nix
    ];

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
    };

    # Open firewall again for cloudflared-tunnel
    firewall.allowedTCPPorts = [ 443 ];

  };

}
