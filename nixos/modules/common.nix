{ config, pkgs, ... }:

{
  imports =
    [ # Some default modules that you should enable on any NixOS Machine
      ./common/autoupgrade.nix # Enable autoupgrade
      ./common/boot.nix # Common boot config options
      ./common/console-options.nix #Sets some default console layout and keyboard options
      ./common/dns.nix # Some default networking options
      ./common/docker.nix # Enable docker & docker-compose
      ./common/firmware.nix # Set firmware options
      ./common/flakes.nix # Enable Flakes
      ./common/git.nix # Set git username and email
      ./common/optimizations.nix # Optimizations for nix-store
      ./common/packages.nix # Install and/or enable some standard packages like nano, ssh, etc...
      ./common/ssh.nix # Enable & set SSH options
      ./common/user.nix # Ability to create a user through services.user
      ./common/vars.nix # Import common variables 
      ./common/networking.nix # Some specific networking settings    
      ./common/check-disk-usage.nix # Check disk usage and send a slack message if it's over a certain threshold
      ./common/github-key.nix # Import github key for flake updates
      ./common/graylog.nix # Enable and configure rsyslog for graylog
      ./common/shell.nix # Shell aliases and tools
    ];

}