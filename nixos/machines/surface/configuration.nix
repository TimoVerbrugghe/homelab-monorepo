# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ssh-keys, ... }:

let 

  hostname = "timo-surface-nixos";
  username = "timo";
  hashedPassword = "$2b$05$m.dX/051IxdlhA2wwOvVduJqbNWC5HCYfDgvI1uuQopPVt/bASpPy";
 
in 

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../modules/common/autoupgrade.nix # Add autoupgrade module
      ../../modules/common/console-options.nix # Add console options
      ../../modules/common/dns.nix # Add my own dns servers
      ../../modules/common/firmware.nix # Enable firmware updates
      ../../modules/common/flakes.nix # Enable flakes
      ../../modules/common/git.nix # Add git configuration
      ../../modules/common/optimizations.nix # Enable nix cache optimizations
      ../../modules/common/packages.nix # Add default packages
      ../../modules/common/vars.nix # Add some default variables
      ../../modules/vscode-server.nix # Enable VS Code server
      ../../modules/tailscale.nix # Common tailscale config options, you need to add a tailscale authkey file to /etc/nixos/tailscale-authkey.nix
    
      # Boot inputs (with specific surface linux settings)
      ./boot.nix
    ];

  ############################
  ## Host Specific Settings ##
  ############################
  system.stateVersion = "24.05";
  
  networking.hostName = "${hostname}"; # Define your hostname.
  hardware.cpu.intel.updateMicrocode = true;
  console.keyMap = "be-latin1";

  # User setup (root user has to be enabled to make it easier for truenas to take ZFS snapshots)

  users.users = {

    ${username} = {
      extraGroups = [ "wheel" "render" "video" "input" "networkmanager" ];
      isNormalUser = true;
      createHome = true;
      initialHashedPassword = "${hashedPassword}";
      openssh.authorizedKeys.keyFiles = [ ssh-keys.outPath ];
    };
  };

  ## SSH setup
  services.openssh = {
    enable = true;
    ports = [ 22 ];
    settings = {
      PasswordAuthentication = true;
      AllowUsers = ["${username}"]; # Allows all users by default. Can be [ "user1" "user2" ]
      UseDns = true;
      X11Forwarding = false;
      PermitRootLogin = "prohibit-password"; # "yes", "without-password", "prohibit-password", "forced-commands-only", "no"
    };
  };

  ## Enable AutoUpgrades using autoupgrade.nix module
  services.autoUpgrade = {
    hostname = "surface";
  };

  ## Passthrough hostname for tailscale
  services.tailscale = {
    hostname = "${hostname}";
  };

  ## Networking setup
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.powersave = true;
  networking.useDHCP = true;

  ## Additional packages
  environment.systemPackages = with pkgs; [
    chromium
    p7zip
    bitwarden-desktop
    gparted
  ];
}
