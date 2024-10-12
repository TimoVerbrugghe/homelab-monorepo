# A nix configuration for an autoinstaller ISO (to be used to install on Surface Laptop)

{ config, pkgs, nixpkgs, ... }:

{
  imports =
    [ 
      # Import minimal ISO CD
      (nixpkgs + /nixos/modules/installer/cd-dvd/installation-cd-graphical-gnome.nix)

      # Import tools (needed for certain options such as system.nixos-generate-config)
      (nixpkgs + /nixos/modules/installer/tools/tools.nix)

        # Provide an initial copy of the NixOS channel so that the user
      # doesn't need to run "nix-channel --update" first.
      (nixpkgs + /nixos/modules/installer/cd-dvd/channel.nix)

    ];

  # Power saving
  services.thermald.enable = true;
  services.auto-cpufreq.enable = true;
  services.auto-cpufreq.settings = {
    battery = {
      governor = "powersave";
      turbo = "never";
    };
    charger = {
      governor = "performance";
      turbo = "auto";
    };
  };

  # Set time correctly when dualbooting with Windows
  time.hardwareClockInLocalTime = true;

  # Enable opengl and 32 bit driver support
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [
      onevpl-intel-gpu
      # vpl-gpu-rt after 24.11
    ];
  };

  # Set specific options for gnome
  services.xserver = {
    displayManager.gdm.enable = true;
    desktopManager.gnome = {
      enable = true;
      # Enable fractional scaling
      extraGSettingsOverridePackages = [ pkgs.gnome.mutter ];
      extraGSettingsOverrides = ''
        [org.gnome.mutter]
        experimental-features=['scale-monitor-framebuffer']
      '';
    };
  };

  # Enable git & sgdisk for partitioning and installing from github flakes later
  # Enabling unfree packages for google-chrome
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    nano
    git
    gptfdisk
    gnome.gnome-tweaks
    gnomeExtensions.dash-to-dock
    gnomeExtensions.window-gestures
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
  ];

  # Making sure DNS works
  networking.nameservers = [
    "1.1.1.1"
    "8.8.8.8"
    "8.8.4.4"
  ];

  ## Enable Flakes
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
        experimental-features = nix-command flakes
    '';
  };

  # ISO Image options
  isoImage.squashfsCompression = "gzip -Xcompression-level 1";
  isoImage.isoBaseName = "nixos-auto-installer";
  isoImage.isoName = "${config.isoImage.isoBaseName}-${config.system.nixos.label}-${pkgs.stdenv.hostPlatform.system}.iso";
  isoImage.makeEfiBootable = true;
  isoImage.makeUsbBootable = true;
  isoImage.volumeID = "NIXOS_ISO";
}

