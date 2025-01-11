## Aelita is a HA VM in my proxmox cluster that only does the following: 
# 1) Run Plex & Jellyfin because they use sqlite databases and they're unstable if those databases are on NFS

{ config, lib, pkgs, ssh-keys, ... }:

let 

  hostname = "aelita";
  username = "aelita";
  hashedPassword = "$y$j9T$Q2d7p39EZ1FvibfhyrQNB1$K5tu7VuyiCaH3fnCwhOA6qYnfNDeYjE3.tYRbYHRBxB";
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
      ../../modules/common.nix
      ../../modules/portainer-server.nix
      ../../modules/tailscale.nix
      ../../modules/vm-options.nix
      ../../modules/vscode-server.nix
      ../../modules/intel-gpu-drivers.nix
    ];

  ############################
  ## Host Specific Settings ##
  ############################
  system.stateVersion = "24.11";
  
  networking.hostName = "${hostname}"; # Define your hostname.
  hardware.cpu.intel.updateMicrocode = true;
  boot.kernelParams = kernelParams;
  boot.extraModprobeConfig = extraModprobeConfig;

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
    defaultGateway = "${config.vars.defaultGateway}";
    interfaces = {
      eth0 = {
        ipv4.addresses  = [
          { address = "${ipAddress}"; prefixLength = 24; }
        ];
      };
    };
  };
  
  # More ram for plex to transcode in
  boot.devShmSize = "70%"; 
}
