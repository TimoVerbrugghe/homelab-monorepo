{ config, lib, pkgs, ssh-keys, ... }:

let

  hostname = "azurenixos";
  username = "azurenixos";
  hashedPassword = "$y$j9T$vopiHdqIsT47sQb/Qme8q0$qjq7MH8n6zESyFUIVASK5iqpUJUA0FC8Q01Xw0hfTQA";

in
{
  imports = [
    # ./hardware-configuration.nix
    ../../modules/tailscale.nix
    # ../../modules/vm-options.nix
    ../../modules/common/flakes.nix # Enable flakes
    ../../modules/common/git.nix # Add git configuration
    ../../modules/common/packages.nix # Add default packages
    ../../modules/tailscale.nix # Common tailscale config options, you need to add a tailscale authkey file to /etc/nixos/tailscale-authkey.nix
    ../../modules/remote-builder.nix # Enable using this machine as remote builder for nixos
    ../../modules/common/user.nix # Enable using this machine as remote builder for nixos
  ];

  ############################
  ## Host Specific Settings ##
  ############################
  system.stateVersion = "24.11";
  
  networking.hostName = "${hostname}"; # Define your hostname.

  # Set up single user using user.nix module
  services.user = {
    user = "${username}";
    hashedPassword = "${hashedPassword}";
  };

  ## Passthrough hostname for tailscale
  services.tailscale = {
    hostname = "${hostname}";
  };

  ## VM Options
  # Enable QEMU guest agent for better VM integration
  services.qemuGuest.enable = true;
  
  # Enable watchdog
  systemd.watchdog.device = "/dev/watchdog";
  systemd.watchdog.runtimeTime = "30s";

  # Enable fstrim so that discarded blocks are recovered on the host
  services.fstrim.enable = true;

  # Enable serial console so that I can access console in proxmox
  boot.kernelParams = [ "console=ttyS0,115200n8" ];

}
