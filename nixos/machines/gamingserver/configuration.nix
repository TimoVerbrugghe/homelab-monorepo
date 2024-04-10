# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ssh-keys, ... }:

let 

  hostname = "gamer";
  username = "gamer";
  hashedPassword = "$y$j9T$OQ3/pU28qXBFymHBymT8l0$ilSqIw/x28PWmGDdN5lXnbj.bt4EXFaQYwfRzC8X1l1";
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
      ../../modules/common.nix # Add default modules
      ../../modules/vscode-server.nix # Enable VS Code server
      ../../modules/tailscale.nix # Common tailscale config options, you need to add a tailscale authkey file to /etc/nixos/tailscale-authkey.nix
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

  # Set up single user using user.nix module
  services.user = {
    user = "${username}";
    hashedPassword = "${hashedPassword}";
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
    usePredictableInterfaceNames = false;
    defaultGateway = "${config.vars.defaultGateway}";
    interfaces = {
      eth2 = {
        ipv4.addresses  = [
          { address = "${ipAddress}"; prefixLength = 24; }
        ];
      };
    };
  };

  #####################
  ## GAMING SETTINGS ##
  #####################
  boot.initrd.kernelModules = [
    "amdgpu"
  ];

  boot.kernelModules = [
    "uinput"
  ];

  networking.networkmanager.enable = true;
  programs.java.enable = true; 
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };

  # Enable MTU probing, as vendor does
  # See: https://github.com/ValveSoftware/SteamOS/issues/1006
  # See also: https://www.reddit.com/r/SteamDeck/comments/ymqvbz/ubisoft_connect_connection_lost_stuck/j36kk4w/?context=3
  boot.kernel.sysctl."net.ipv4.tcp_mtu_probing" = true;

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };
  services.xserver.videoDrivers = ["amdgpu"];
  services.xserver.enable = true;
  services.xserver.displayManager = {
    
    defaultSession = "plasmawayland";
    autoLogin.enable = true;
    autoLogin.user = "gamer";
    sddm = {
      enable = true;
      wayland.enable = true;
      wayland.compositor = "kwin";
    };
  };
  services.xserver.desktopManager.plasma5.enable = true;

  services.input-remapper.enable = true;

  ## Sunshine config
  environment.systemPackages = with pkgs; [
    sunshine
    chromium

    # Emulators
    retroarchFull
    duckstation
    cemu
    dolphin-emu
    melonDS
    rpcs3
    mgba
    pcsx2
    ppsspp
    # emulationstation-de
    ryujinx

    (pkgs.callPackage ./emulationstation-de {})
  ];

  # Need this for emulationstation-de
  nixpkgs.config.permittedInsecurePackages = [
    "freeimage-unstable-2021-11-01"
  ];

  security.wrappers.sunshine = {
      owner = "root";
      group = "root";
      capabilities = "cap_sys_admin+p";
      source = "${pkgs.sunshine}/bin/sunshine";
  };

  systemd.user.services.sunshine =
    {
      description = "sunshine";
      wantedBy = [ "graphical-session.target" ];
      serviceConfig = {
        ExecStart = "${config.security.wrapperDir}/sunshine";
      };
    };

  services.avahi.publish.enable = true;
  services.avahi.publish.userServices = true;

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 47984 47989 47990 48010 ];
    allowedUDPPortRanges = [
      { from = 47998; to = 48000; }
    ];
  };

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

}
