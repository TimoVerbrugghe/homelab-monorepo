{ config, pkgs, ... }:

{
  imports =
    [ # Some default modules that you should enable on any NixOS Machine
      ./user.nix # Ability to create a user through services.user
      ./vars.nix # Import common variables
      ./optimizations.nix # Optimizations for nix-store
      ./boot.nix # Common boot config options
      ./packages.nix # Install and/or enable some standard packages like nano, ssh, etc...
      ./docker.nix # Enable docker & docker-compose
      ./flakes.nix # Enable Flakes
      ./autoupgrade.nix # Enable autoupgrade
      ./dns.nix # Some default networking options
      ./git.nix # Set git username and email
      ./firmware.nix # Set firmware options
      ./ssh.nix # Enable & set SSH options
      ./console-options.nix #Sets some default console layout and keyboard options
    ];

}