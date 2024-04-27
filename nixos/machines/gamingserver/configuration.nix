# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ssh-keys, ... }:

let 

  hostname = "gamer";
  username = "gamer";
  hashedPassword = "$y$j9T$OQ3/pU28qXBFymHBymT8l0$ilSqIw/x28PWmGDdN5lXnbj.bt4EXFaQYwfRzC8X1l1";
  ipAddress = "10.10.10.15";
  kernelParams = [
  ];
  
  extraModprobeConfig = ''
  '';

in 

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../modules/common.nix # Add default modules
      ../../modules/vscode-server.nix # Enable VS Code server
      ../../modules/tailscale.nix # Common tailscale config options, you need to add a tailscale authkey file to /etc/nixos/tailscale-authkey.nix
    
      # Gaming specific inputs
      ./input-remapper.nix
      ./sound.nix
      ./display.nix
      ./sunshine.nix
      ./steam.nix
      ./emulators.nix
      ./gaming-optimizations.nix
      ./backup-config.nix
    ];

  ############################
  ## Host Specific Settings ##
  ############################
  system.stateVersion = "23.11";
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
    networkmanager.ensureProfiles.profiles = {
      enp6s0f1 = {
        connection = {
          id = "10Gbps Connection";
          uuid = "4d71d0d6-76b9-4bd9-bbf3-4bfef80a28bb";
          type = "ethernet";
          autoconnect-priority = "1";
          autoconnect = "true";
          interface-name = "enp6s0f1";
        };
        ethernet = {
          mac-address = "6C:92:BF:5E:38:43";
        };
        ipv4 = {
          address1 = "10.10.10.15/24,10.10.10.1";
          method = "manual";
        };
        ipv6 = {
          addr-gen-mode = "stable-privacy";
          method = "ignore";
        };
      };
    };
    defaultGateway = "${config.vars.defaultGateway}";
    interfaces = {
      enp6s0f1 = {
        ipv4.addresses  = [
          { address = "${ipAddress}"; prefixLength = 24; }
        ];
      };
    };
  };

  ## Additional packages
  environment.systemPackages = with pkgs; [
    chromium
    p7zip
    gamescope
  ];
}
