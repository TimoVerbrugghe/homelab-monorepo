# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

let 

  hostname = "nixos";
  username = "nixos";
  hashedPassword = "$y$j9T$WICga7IOUb026e7gehsQi.$ZrC/f/Ar/VeP2dRqPIA7PXM0t4EsvoUbx.PueUJPFW8";
  ipAddress = "192.168.0.3";
  defaultGateway = "192.168.0.1";
  kernelParams = [
     "i915.enable_guc=2" # Enable Intel Quicksync
  ];
  
  # Load bochs (proxmox standard VGA driver) after the i915 driver so that we can use noVNC while iGPU was passed through
  extraModprobeConfig = ''
  softdep bochs pre: i915
  '';

  tailscaleDomain = "mermaid-alpha.ts.net";

  portainerCompose = pkgs.writeText "portainer-docker-compose.yml" ''
    version: '3.8'

    name: portainer

    services:
      portainer:
        image: portainer/portainer-ce:latest
        container_name: portainer
        hostname: portainer
        restart: always
        volumes:
          - /var/run/docker.sock:/var/run/docker.sock
          - portainer:/data
        ports:
          - "8000:8000"
          - "9443:9443"
    
    volumes:
      portainer:

    networks:
      dockerproxy:
  '';

in 

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      
      # Include tailscale authkey file, you need to put this manually in your nixos install
      /etc/nixos/tailscale-authkey.nix
    ];

  system.stateVersion = "23.11";

  ## Hardware & Firmware settings
  hardware.cpu.intel.updateMicrocode = true;
	hardware.enableRedistributableFirmware = true;
	hardware.enableAllFirmware = true;

  ## Boot settings
  boot.kernelParams = kernelParams;
  boot.extraModprobeConfig = extraModprobeConfig;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 3;

  # Making sure we're running latest linux kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Reduce swappiness
  boot.kernel.sysctl = { "vm.swappiness" = 20;};

  ## Enable Flakes
  nix = {
    package = pkgs.nixVersions.stable;
    extraOptions = ''
        experimental-features = nix-command flakes
    '';
  };

  ## Console, layout options
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "be-latin1";
  time.timeZone = "Europe/Brussels";

  ## VM Options
  # Enable QEMU guest agent for better VM integration
  services.qemuGuest.enable = true;
  
  # Enable watchdog
  systemd.watchdog.device = "/dev/watchdog";
  systemd.watchdog.runtimeTime = "30s";

  ## Autoupgrade settings
  system.autoUpgrade = {
    enable = true;
    flake = "github:TimoVerbrugghe/homelab-monorepo?dir=nixos#david";
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

  ## Install Intel GPU drivers
  nixpkgs.config.allowUnfree = true;

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      # Quick Sync Video
      vpl-gpu-rt

      # General Intel GPU iHD driver
      intel-media-driver

      # OpenCL runtime
      intel-compute-runtime

      # Use VDPAU (normally only supported on NVIDIA/AMD gpus on intel gpus)
      libvdpau-va-gl
    ];
  };

  ## Nix-store optimizations
  nix.optimise.automatic = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  ## Networking setup
  networking = {
    firewall.enable = true;
    firewall.allowPing = true;

    hostName = "${hostname}";
    usePredictableInterfaceNames = false;
    defaultGateway = "${defaultGateway}";
    nameservers = [
      "1.1.1.1"
      "8.8.8.8"
      "8.8.4.4"
    ];
    interfaces = {
      eth0 = {
        ipv4.addresses  = [
          { address = "${ipAddress}"; prefixLength = 24; }
        ];
      };
    };
  };

  ## Increase UDP Buffer size to 25 MB
  boot.kernel.sysctl = { 
    "net.core.rmem_max" = 25000000; 
    "net.core.wmem_max" = 25000000; 
    "net.core.rmem_default" = 25000000;
    "net.core.wmem_default" = 25000000;
  };

  ## SMB shares
  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        workgroup = "WORKGROUP";
        "server string" = "smbnix";
        "netbios name" = "smbnix";
        security = "user";
        "hosts allow" = "192.168.0. 127.0.0.1 localhost";
        "hosts deny" = "0.0.0.0/0";
        "guest account" = "nobody";
        "map to guest" = "bad user";
        "server role" = "standalone server";
      };
      movies = {
        path = "/media/movies";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "yes";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "${username}";
        "force group" = "users";
      };
      tvshows = {
        path = "/media/tvshows";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "yes";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "${username}";
        "force group" = "users";
      };
      downloads = {
        path = "/media/downloads";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "yes";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "${username}";
        "force group" = "users";
      };
      other = {
        path = "/media/other";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "yes";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "${username}";
        "force group" = "users";
      };
    };
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
      domain = true;
      hinfo = true;
      userServices = true;
      workstation = true;
    };
    extraServiceFiles = {
      smb = ''
        <?xml version="1.0" standalone='no'?><!--*-nxml-*-->
        <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
        <service-group>
          <name replace-wildcards="yes">%h</name>
          <service>
            <type>_smb._tcp</type>
            <port>445</port>
            <txt-record>model=Xserve</txt-record>
          </service>
        </service-group>
      '';
    };
  };

  services.samba-wsdd = {
    enable = true;
    discovery = true;
    openFirewall = true;
  };

  # Add user to smbpasswd

  systemd.services.samba-smbpasswd = {
    enable = true;
    description = "Add user to smbpasswd with default password nixos";
    path = with pkgs; [
      samba
    ];
    script = ''
    printf "nixos\nnixos\n" | smbpasswd -a -s nixos && echo "smbpasswd applied successfully"
    '';
    serviceConfig = {
      Type = "oneshot";
    };
    wantedBy = [ "multi-user.target" ];
  };

  ## Tailscale setup
  services.tailscale.enable = true;
  services.tailscale.useRoutingFeatures = "both";
  services.tailscale.extraUpFlags = [
    "--advertise-exit-node"
    "--advertise-routes=192.168.0.0/24"
  ];

  # Tailscale Authkey
  services.tailscale.authKeyFile = pkgs.writeText "tailscale_authkey" ''
    ${config.tailscaleAuthKey}
  '';

  systemd.services.tailscale-cert-renewal = {
    enable = true;
    description = "Renew Tailscale certificates weekly";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.tailscale}/bin/tailscale cert ${hostname}.${tailscaleDomain}";
    };
    wantedBy = [ "multi-user.target" ];
    after = ["network-online.target"];
    wants = ["network-online.target"];
  };

  # Renew tailscale certs on weekly basis and on startup
  systemd.timers.tailscale-cert-renewal = {
    description = "Run Tailscale certificate renewal weekly";
    timerConfig = {
      OnCalendar = "weekly";
      Unit = "tailscale-cert-renewal.service";
    };
  };

  # Set up single user
  users.mutableUsers = false;

  users.users = {
    ${username} = {
      extraGroups = [ "wheel" "docker" "render" "video" ];
      isNormalUser = true;
      createHome = true;
      hashedPassword = "${hashedPassword}";
      uid = 1000;
    };
  };

  users.groups = {
    ${username} = {
      gid = 1000;
      members = [ "${username}" ];
    };
  };

  ### Install packages ###
  environment.systemPackages = with pkgs; [
    vim
    nano
    wget
    pciutils
    jq
    iputils
    neofetch
    clinfo
    libva-utils
    intel-gpu-tools
    docker-compose
    tmux
    nfs-utils
  ];

  ## Enable SSH
  services.openssh.enable = true;

  ## Docker
  virtualisation.docker.enable = true;
  virtualisation.docker.autoPrune.enable = true;
  virtualisation.docker.autoPrune.dates = "weekly";
  virtualisation.docker.enableOnBoot = true;
  virtualisation.docker.liveRestore = false; # will affect running containers when restarting docker daemon, but resolves stuck shutdown/reboot

  ## Enable Portainer at startup
  systemd.services.portainer = {
    enable = true;
    description = "Portainer";
    after = [ "network-online.target" "docker.service" "docker.socket"];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      ExecStart = "${pkgs.docker-compose}/bin/docker-compose -f ${portainerCompose} up";
      ExecStop = "${pkgs.docker-compose}/bin/docker-compose ${portainerCompose} down";
      Restart = "always";
      RestartSec = "30s";
    };
  };

  ## Add this systemd service because docker keeps quitting containers on startup that I have connected with tailscale even with docker compose healthchecks -_-'

  systemd.services.docker-container-restart = {
    description = "Periodically restart Docker containers with specific error - cannot join network of running container";
    after = [ "network-online.target" "docker.service" "docker.socket"];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    enable = true;
    path = with pkgs; [
      docker
    ];
    script = ''
      docker ps -a --filter "status=exited" --format "{{.ID}}" | while read -r container_id; do
        error=$(docker inspect --format "{{.State.Error}}" "$container_id")
        if [[ "$error" == *"cannot join network of a non running container"* ]]; then
          docker restart "$container_id"
        fi
      done
    '';
    serviceConfig = {
      User = "root";
      Group = "root";
      Type = "oneshot";
      restart = "no";
    };
    
  };

  systemd.timers.docker-container-restart = {
    description = "Timer to periodically restart Docker containers";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*:0/5";  # Run every 5 minutes
      Persistent = true;
    };
  };

  # Add a dns manager so that tailscale does not overwrite /etc/resolv.conf. Ensures that docker dns keeps working
  services.resolved = {
    enable = true;
    dnssec = "true";
    domains = [ "~." ];
    fallbackDns = [ "8.8.8.8" "8.8.4.4" "1.1.1.1" ];
    dnsovertls = "true";
  };
  }
