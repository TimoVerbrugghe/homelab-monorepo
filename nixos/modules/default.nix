{ config, pkgs, ... }:

{
  imports =
    [ # Some default modules that you should enable on any NixOS Machine
      ./vscode-server.nix # Enable VS Code server
      ./tailscale.nix # Common tailscale config options, you need to add a tailscale authkey file to /etc/nixos/tailscale-authkey
      ./user.nix # Ability to create a user through services.user
      ./vars.nix # Import common variables
      ./optimizations.nix # Optimizations for nix-store
      ./boot.nix # Common boot config options
      ./default-packages.nix # Install and/or enable some standard packages like nano, ssh, etc...
      ./docker.nix # Enable docker & docker-compose
      ./flakes.nix # Enable Flakes
      ./intel-gpu-drivers.nix # Install Intel GPU drivers
    ];

}