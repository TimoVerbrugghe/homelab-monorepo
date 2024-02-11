# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ inputs, config, lib, pkgs, ssh-keys, ... }:

let 

  hostname = "nixos";
  username = "nixos";
  hashedPassword = "$6$DZe4T.fUOG9S2wRd$noj16mOHH4RR21wIxw.IsrAIR4DK0s8B8P7Zoqt8BfYILE4ZyJdYR/AxSFDtNnYI170cNX7eRHgCMFb12LAqK0";
  timezone = "Europe/Brussels";
  kernelParams = [
     "i915.enable_guc=2" # Enable Intel Quicksync
  ];
  inherit (inputs) ssh-keys;

in 

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      /etc/nixos/tailscale-authkey.nix
      ../../modules/boot.nix # Common boot config options
      ../../modules/default-packages.nix # Install and/or enable some standard packages like nano, ssh, etc...
      ../../modules/docker.nix # Enable docker & docker-compose
      ../../modules/flakes.nix # Enable Flakes
      ../../modules/intel-gpu-drivers.nix # Install Intel GPU drivers
      ../../modules/optimizations.nix # Optimizations for nix-store
      ../../modules/portainer.nix # Enable Portainer at startup
      ../../modules/tailscale.nix # Common tailscale config options
      ../../modules/user.nix # Ability to create a user through services.user
      ../../modules/vars.nix # Import common variables
      ../../modules/vm-options.nix # Some default options you should enable on VMs
      ../../modules/vscode-server.nix # Enable VS Code server      
    ];

  ############################
  ## Host Specific Settings ##
  ############################
  system.stateVersion = "23.11";
  networking.hostName = "${hostname}"; # Define your hostname.
  boot.kernelParams = kernelParams;
  time.timeZone = "${timezone}";

  # Users
  services.user = {
    user = "${username}";
    hashedPassword = "${hashedPassword}";
  };

  # Tailscale Authkey
  services.tailscale.authKeyFile = pkgs.writeText "tailscale_authkey" ''
    ${config.tailscaleAuthKey}
  '';

  ## Enable AutoUpgrades
  system.autoUpgrade = {
    enable = true;
    flake = "github:TimoVerbrugghe/homelab-monorepo?dir=nixos#${hostname}";
    flags = [
      "--update-input"
      "nixpkgs"
      "--no-write-lock-file"
      "--refresh" # so that latest commits to github repo get downloaded
      "--impure" # needed because I'm referencing a file with variables locally on the system, have to find a better way to deal with secrets
    ];
    dates = "05:00";
    randomizedDelaySec = "45min";
  };

}
