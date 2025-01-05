## Aelita is a HA VM in my proxmox cluster that only has 1 function: expose an NFS server which will be used as my HA storage in my kubernetes cluster

{ config, lib, pkgs, ssh-keys, ... }:

let 

  hostname = "aelita";
  username = "aelita";
  hashedPassword = "$y$j9T$Q2d7p39EZ1FvibfhyrQNB1$K5tu7VuyiCaH3fnCwhOA6qYnfNDeYjE3.tYRbYHRBxB";
  ipAddress = "10.10.10.12";

in 

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../modules/vm-options.nix # Some default options you should enable on VMs
      ../../modules/common/autoupgrade.nix # Enable auto-upgrades
      ../../modules/common/boot.nix # Boot configuration
      ../../modules/common/dns.nix # DNS configuration
      ../../modules/common/firmware.nix # Firmware configuration
      ../../modules/common/flakes.nix # Enable Flakes
      ../../modules/common/graylog.nix # Graylog configuration
      ../../modules/common/networking.nix # Networking configuration
      ../../modules/common/optimizations.nix # Optimization configuration
      ../../modules/common/packages.nix # Package configuration
      ../../modules/common/ssh.nix # SSH configuration
      ../../modules/common/user.nix # User configuration
      ../../modules/common/vars.nix # Variables configuration

    ];

  ############################
  ## Host Specific Settings ##
  ############################
  system.stateVersion = "24.11";
  
  networking.hostName = "${hostname}"; # Define your hostname.
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

  ### NFS Setup for Kubernetes (this node is a HA node on proxmox providing storage to my kubernetes cluster)
  # Creating directories on the system - having "-" at the end tells systemd not to delete these folders
  systemd.tmpfiles.rules = [
    "d /nfs 0770 nobody nogroup -"
    "d /nfs/portainer 0770 nobody nogroup -"
    "d /nfs/bitwarden 0770 nobody nogroup -"
    "d /nfs/bitwarden-export 0770 nobody nogroup -"
  ];

  # NFS Server Configuration
  services.nfs.server.enable = true;
  services.nfs.server.exports = ''
    /nfs                  ${ipAddress}(sec=sys,rw,anonuid=0,anongid=65534,insecure,no_subtree_check)
    /nfs/portainer        ${ipAddress}(sec=sys,rw,anonuid=0,anongid=65534,insecure,no_subtree_check)
    /nfs/bitwarden        ${ipAddress}(sec=sys,rw,anonuid=0,anongid=65534,insecure,no_subtree_check)
    /nfs/bitwarden-export ${ipAddress}(sec=sys,rw,anonuid=0,anongid=65534,insecure,no_subtree_check)
  '';

}
