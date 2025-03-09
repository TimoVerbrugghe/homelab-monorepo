# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ssh-keys, ... }:

let 

  hostname = "gamer";
  username = "gamer";
  hashedPassword = "$y$j9T$OQ3/pU28qXBFymHBymT8l0$ilSqIw/x28PWmGDdN5lXnbj.bt4EXFaQYwfRzC8X1l1";
  rootHashedPassword = "$y$j9T$7E6wHbcJEJQPiXVueGTNV1$M7mPU6KWENkeSHJbvplkHVZyQgc97cxavaFB.uziYC.";
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
      ../../modules/common/check-disk-usage.nix # needs a slack webhook url file in /etc/nixos/slack-webhook-url.nix
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
      # ../../modules/remote-builder.nix # Enable using this machine as remote builder for nixos
      ../../modules/common/graylog.nix # Enable and configure rsyslog for graylog
      
      # Cannot add this now because it conflicts with using gamingserver as remotebuilder
      # ../../modules/common/shell.nix # Add shell aliases and tools

      # Boot inputs (with specific zfs settings)
      ./boot.nix

      # Gaming specific inputs
      # ./input-remapper.nix
      # ./sound.nix
      # ./display.nix
      # ./sunshine.nix
      # ./gamelaunchers.nix
      # ./emulators.nix
      # ./gaming-optimizations.nix
      ./rom-sync.nix
      ./zfs.nix
      ./controllers.nix

      # # Sleep options
      ./sleep.nix
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

  # User setup (root user has to be enabled to make it easier for truenas to take ZFS snapshots)

  users.mutableUsers = false;

  users.users = {

    ${username} = {
      # Need to add user to the group "audio" so that sunshine is able to capture audio sinks & passhthrough sound
      extraGroups = [ "wheel" "render" "video" "input" "audio" ];
      isNormalUser = true;
      createHome = true;
      hashedPassword = "${hashedPassword}";
      openssh.authorizedKeys.keyFiles = [ ssh-keys.outPath ];
    };

    root = {
      hashedPassword = "${rootHashedPassword}";

      # Add public key for TheFactory TrueNAS so that TrueNAS can take zfs snapshots using a replication task
      openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC2BZgvsUxnbuSWfVaL7aP9UPGHIkc4SRwiwTU0uXVY35v8wBCfVmeHj552IjcluQy7JReQCmLDm6lepWPWjMagr9aw/CaXLJ/cvMHcAqaPDdVkuBX9M0xEq60isr9yj9gUq+FZW/8c1WAbaAVzD2M2PzZG19JPmvqrljWD90YTpRZbM5vWXYenVXj97t8OaRGnXrkENYfyIb2SxPLcbtou1W9IE6jLiNpsW8vqZgcPWwBfG4BJ06xwrgdrSjIsjBwVia9spHBnk3uz/F5/ziQvQRZfqDsXFAUX2V3VD0LNg4Vx3SAbN8cQYZraFnZHsyzxFPCdJsYroVsMFmhZN0Z1V0k54X+wp/DnUs4lU36jGIWEHW3ibvHD+BETUwb2OrRWNZLhmFTFeuk/J11nb8zCJwPkRuO1tH87KZQSZFLT3l1oCzEXx1UQecIxr+0uSk9N64OSV0+NjosAXc4kt2YmlV2P93wM4uadpUliZZXNM/EBoBDCS0jABAX12wniTq0= root@TheFactory"];
    };
  };

  ## SSH setup
  services.openssh = {
    enable = true;
    ports = [ 22 ];
    settings = {
      PasswordAuthentication = true;
      # AllowUsers = ["root" "${username}"]; # Allows all users by default. Can be [ "user1" "user2" ]
      UseDns = true;
      X11Forwarding = false;
      PermitRootLogin = "prohibit-password"; # "yes", "without-password", "prohibit-password", "forced-commands-only", "no"
    };
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
    bitwarden-desktop
  ];
}
