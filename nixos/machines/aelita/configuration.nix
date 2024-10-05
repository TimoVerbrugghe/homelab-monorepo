# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ssh-keys, ... }:

let 

  hostname = "aelita";
  username = "aelita";
  hashedPassword = "$y$j9T$3CG7KE5qgfuBLRxsUIgN8/$DG1HbNtEa9VA.oM6ZFyCicO9uJOSwFl.nJo0HNbtIv5";
  ipAddress = "10.10.10.11";
  kernelParams = [
  ];
  extraModprobeConfig = ''
  '';

in 

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../modules/common.nix # Add default modules (some default settings, user setup, boot setup, etc...)
      ../../modules/portainer-agent.nix # Enable Portainer Server at startup
      ../../modules/vm-options.nix # Some default options you should enable on VMs    
      ../../modules/vscode-server.nix # Enable VS Code server
      ../../modules/tailscale.nix # Common tailscale config options, you need to add a tailscale authkey file to /etc/nixos/tailscale-authkey
      ../../modules/cloudflare.nix # Get certs using nixos's built-in acme function (which uses lego), you need to add a cloudflare api key file to /etc/nixos/cloudflare-keys.nix
      ../../modules/check-disk-usage.nix # Notify if disk usage is above 80%, needs a teams webhook url file in /etc/nixos/teams-webhook-url.nix
    ];

  ############################
  ## Host Specific Settings ##
  ############################
  networking.hostName = "${hostname}"; # Define your hostname.
  boot.kernelParams = kernelParams;
  boot.extraModprobeConfig = extraModprobeConfig;
  hardware.cpu.amd.updateMicrocode = true;
  console.keyMap = "us"; # truenas spice display will translate be-latin keymap to us keymap

  # Set up single user using user.nix module
  services.user = {
    user = "${username}";
    hashedPassword = "${hashedPassword}";
  };

  ## Enable AutoUpgrades using autoupgrade.nix module
  services.autoUpgrade = {
    hostname = "${hostname}";
  };

  # Passthrough hostname for tailscale
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
					{ address = "10.10.10.23"; prefixLength = 32; } # Adguardhome IP Address
				];
			};
    };
  };

}
