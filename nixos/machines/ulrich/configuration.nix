# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ssh-keys, ... }:

let 

  hostname = "ulrich";
  username = "ulrich";
  hashedPassword = "$y$j9T$ImIzH0p/iMPnmB/75rC0e1$ufXQxWY9QTJa2k6z/26T/tGPUxYuRHDOi4FPdwSiMh1";
  ipAddress = "10.10.10.8";
  adguardhomeIpAddress = "10.10.10.21";

in 

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../modules/common.nix # Add default modules (some default settings, user setup, boot setup, etc...) - needs a slack webhook url file in /etc/nixos/slack-webhook-url.nix
      ../../modules/portainer-agent.nix # Enable Portainer Server at startup
      ../../modules/vm-options.nix # Some default options you should enable on VMs
      ../../modules/vscode-server.nix # Enable VS Code server
      ../../modules/tailscale.nix # Common tailscale config options, you need to add a tailscale authkey file to /etc/nixos/tailscale-authkey.nix
      ../../modules/acme.nix # Get certs using nixos's built-in acme function (which uses lego), you need to add a cloudflare api key file to /etc/nixos/cloudflare-apikey.nix
      ../../modules/cloudflare-tunnel.nix # Enable Cloudflare Tunnel
      ../../modules/remote-builder.nix # Enable using this machine as remote builder for nixos
    ];

  ############################
  ## Host Specific Settings ##
  ############################
  system.stateVersion = "23.11";
  
  networking.hostName = "${hostname}"; # Define your hostname.
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

		macvlans = {
      macvlan0 = {
			  interface = "eth0";
			  mode = "bridge";
        macAddress = "02:42:0a:0a:0a:13";
		  };
    };

    usePredictableInterfaceNames = false;
    defaultGateway = "${config.vars.defaultGateway}";
    
    interfaces = {
      # Keep eth0 without IP but allow it to be up for macvlan
      eth0 = {
        useDHCP = false;
      };
			
      macvlan0 = {
        useDHCP = false;
				ipv4.addresses =  [ 
					{ address = "${ipAddress}"; prefixLength = 24; }
				];
        ipv4.routes = [
					{ address = "${adguardhomeIpAddress}"; prefixLength = 32; }
				];
			};
    };
  };
}
