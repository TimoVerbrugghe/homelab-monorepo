{ config, pkgs, nixpkgs-unstable, ... }:

{
  # Enable git & sgdisk for partitioning and installing from github flakes later
  # Enabling unfree packages for google-chrome
  nixpkgs.config.allowUnfree = true;

  ## Additional packages
  environment.systemPackages = with pkgs; [
    (google-chrome.override {
      commandLineArgs = [
        "--enable-features=VaapiVideoDecodeLinuxGL"
        "--enable-features=TouchpadOverscrollHistoryNavigation" # Enable touchpad back/forward navigation
        "--ozone-platform=wayland" # Enable zoom in with 2 fingers touchpad
      ];
    })
    p7zip
    bitwarden-desktop
    vscode
    nano
    git
    gptfdisk
    evtest
    lm_sensors
    vlc
    plexamp
    plex-media-player
    slack
    moonlight-qt
    gparted
    spotify
    element-desktop
    xournalpp
    trayscale
    (pkgs.callPackage ./chrome-apps/package.nix {})
    localsend
    gimp
    qemu
    
    # Let's see if I can get this device enrolled...
    intune-portal
    microsoft-edge
    
    # RPCBind necessary for NFS
    kodi-wayland
    rpcbind
    libreoffice

    # direnv is needed for VSCode nixos extension
    direnv
  ];

  virtualisation.libvirtd = {
    enable = true;

    # Needed for shared folders between host & VMs
    qemu.vhostUserPackages = with pkgs; [ virtiofsd ];
  };

  programs.virt-manager.enable = true;

  programs.java.enable = true; 
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
  };

  networking.firewall.allowedTCPPorts = [
    # localsend
    53317 
  ];
  networking.firewall.allowedUDPPorts = [
    # localsend
    53317 
  ];

}
