# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, inputs, lib, pkgs, ssh-keys, ... }:

let 

  hostname = "timo-surface-nixos";
  username = "Timo";
  hashedPassword = "$2b$05$m.dX/051IxdlhA2wwOvVduJqbNWC5HCYfDgvI1uuQopPVt/bASpPy";

in 

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../modules/common/autoupgrade.nix # Add autoupgrade module
      ../../modules/common/console-options.nix # Add console options
      ../../modules/common/firmware.nix # Enable firmware updates
      ../../modules/common/flakes.nix # Enable flakes
      ../../modules/common/git.nix # Add git configuration
      ../../modules/common/optimizations.nix # Enable nix cache optimizations
      ../../modules/common/packages.nix # Add default packages
      ../../modules/common/vars.nix # Add some default variables
      ../../modules/vscode-server.nix # Enable VS Code server
      ../../modules/common/github-key.nix # Add GitHub PAT key for flake updates
      ../../modules/common/docker.nix # Install docker
      ../../modules/common/shell.nix # Add shell aliases and tools

      # Boot inputs (with specific surface linux settings)
      ./boot.nix

      # Applications
      ./apps.nix

      # Desktop Environment
      ./display.nix
      ./gnome.nix

      # Hardware additional configs
      ./networking.nix
      ./powermanagement.nix
      ./secureboot/secureboot.nix

      # Custom surface_gpe kernel module for Lid switch
      ./surface-gpe/surface_gpe.nix

      # Enable distributed builds (using local nixos server VMs as remote builders)
      ./distributed-builds.nix

      # Surface specifc shellaliases
      ./shell.nix

      # Scanner
      ./scan.nix

      # Sleep options
      ./sleep.nix

    ];

  ############################
  ## Host Specific Settings ##
  ############################
  system.stateVersion = "24.05";
  
  networking.hostName = "${hostname}"; # Define your hostname.
  hardware.cpu.intel.updateMicrocode = true;

  # User setup
  users = {
    users = {
      ${username} = {
        extraGroups = [ "wheel" "render" "video" "input" "networkmanager" "surface-control" "scanner" "lp" ];
        isNormalUser = true;
        createHome = true;
        initialHashedPassword = "${hashedPassword}";
        openssh.authorizedKeys.keyFiles = [ ssh-keys.outPath ];
      };
    };
  };

  ## SSH setup
  services.openssh = {
    enable = true;
    ports = [ 22 ];
    settings = {
      PasswordAuthentication = true;
      # AllowUsers = ["${username}"]; # Allows all users by default. Can be [ "user1" "user2" ]
      UseDns = true;
      X11Forwarding = false;
      PermitRootLogin = "prohibit-password"; # "yes", "without-password", "prohibit-password", "forced-commands-only", "no"
    };
  };

  ## Enable AutoUpgrades using autoupgrade.nix module
  services.autoUpgrade = {
    hostname = "surface";
  };

  # Passthrough hostname for tailscale
  services.tailscale = {
    enable = true;
    openFirewall = true;

    # Needed for trayscale to work
    extraUpFlags = [
      "--operator ${username}"
    ];
  };

  # Set time correctly when dualbooting with Windows
  time.hardwareClockInLocalTime = true;

  # Enable Thunderbolt support
  services.hardware.bolt.enable = true;

  # Trying to not have gnome crash on login (sometimes) - related to https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false; 

  # Lower timeout on systemd service stop/restart (allows for fast shutdown/reboot)
  systemd.extraConfig = ''
    DefaultTimeoutStopSec=10s
  '';

  # Specific surface stuff that's needed
  services.iptsd.enable = lib.mkDefault true;
  environment.systemPackages = [ pkgs.surface-control ];
}
