# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

let 
  portainerCompose = pkgs.writeText "portainer-docker-compose.yml" ''
    version: '3.8'

    services:
      portainer:
        image: portainer/portainer-ce:latest
        container_name: portainer
        restart: always
        volumes:
          - /var/run/docker.sock:/var/run/docker.sock
          - portainer:/data
        ports:
          - "8000:8000"
          - "9443:9443"
    
    volumes:
        portainer:
  '';

  tailscaleDomain = "<INSERT TAILSCALE DOMAIN HERE>";
  tailscaleAuthKey = pkgs.writeText "tailscale_authkey" ''
  <INSERT TAILSCALE KEY HERE>
  '';

  sshKeysUrl = "";
  sshKeysSHA = "";

in 
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  ## Boot Configuration
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  # Making sure we're running latest linux kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [
    "i915.enable_guc=2"
  ];

  ## Networking
  networking.hostName = "nixos"; # Define your hostname.
  services.tailscale.enable = true;
  services.tailscale.authKeyFile = "${tailscaleAuthKey}";

  # Time Settings
  time.timeZone = "Europe/Brussels";

  # Users
  users.users.nixos = {
    isNormalUser = true;
    home = "/home/nixos";
    # Wheel group enables sudo, render and video groups for iGPU transcoding
    extraGroups = [ "wheel" "docker" "render" "video" ];
  };

  # Enable fix so that VS Code remote works
  programs.nix-ld.enable = true;

  # Enable QEMU guest agent for better VM integration
  services.qemuGuest.enable = true;

  # Enable watchdog
  systemd.watchdog.device = "/dev/watchdog";
  systemd.watchdog.runtimeTime = "30s";

  # Increase UDP Buffer size to improve plex performance (since it's running on UDP ports)
  boot.kernel.sysctl = { "net.core.rmem_max" = 2500000; "net.core.wmem_max" = 25000000; };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Optimizations
  nix.optimise.automatic = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  ### Install packages ###
  nixpkgs.config.allowUnfree = true; # For Intel GPU drivers & vscode.fhs

  environment.systemPackages = with pkgs; [
    vim
    nano
    wget
    clinfo
    libva-utils
    intel-gpu-tools
    docker-compose
    pciutils
    vscode.fhs
  ];

  # Install Intel GPU Drivers
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-compute-runtime
    ];
  };

  # Enable Docker
  virtualisation.docker.enable = true;
  virtualisation.docker.autoPrune.enable = true;
  virtualisation.docker.autoPrune.dates = "weekly";
  virtualisation.docker.enableOnBoot = true;

  ## Services to have enabled at startup
  systemd.services = [ 
      portainer = {
        enable = true;
        description = "Portainer";
        after = [ "network.target" "docker.service" "docker.socket"];
        wantedBy = [ "multi-user.target" ];

        serviceConfig = {
          ExecStart = "${pkgs.docker-compose}/bin/docker-compose -f ${portainerCompose} up";
          ExecStop = "${pkgs.docker-compose}/bin/docker-compose ${portainerCompose} down";
          Restart = "always";
          RestartSec = "30s";
        }
      },
      tailscale-cert-renewal = {
          enable = true;
          description = "Renew Tailscale certificates weekly";
          serviceConfig = {
            Type = "oneshot";
            ExecStart = "${pkgs.tailscale}/bin/tailscale cert ${tailscaleDomain}";
          };
          wantedBy = [ "multi-user.target" ];
          after = ["network.target"];
      },
      code-tunnel = {
        enable = true;
        description = "Enable VS Code tunnel";
        serviceConfig = {
          User = "nixos";
          Group = "nixos";
          Type = "simple";
          ExecStart = "${pkgs.vscode.fhs}/bin/code tunnel --accept-server-license-terms --cli-data-dir /home/nixos/.vscode-cli";
        };
        wantedBy = [ "default.target" ];
        after = ["network.target"];
      }
  ];

  # Renew tailscale certs on weekly basis and on startup
  systemd.timers.tailscale-cert-renewal = {
    description = "Run Tailscale certificate renewal weekly";
    timerConfig = {
      OnCalendar = "weekly";
      Unit = "tailscale-cert-renewal.service";
    };
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "23.11"; # Did you read the comment?

}