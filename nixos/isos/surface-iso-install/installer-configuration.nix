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

      # Trying to mimic as much as possible the final installation
      ../../machines/surface/apps.nix
      ../../machines/surface/display.nix
      ../../machines/surface/gnome.nix
      ../../machines/surface/powermanagement.nix
      ../../machines/surface/networking.nix

    ];

  # Set time correctly when dualbooting with Windows
  time.hardwareClockInLocalTime = true;

  # Making sure DNS works
  networking.nameservers = [
    "1.1.1.1"
    "8.8.8.8"
    "8.8.4.4"
  ];

  ## Enable Flakes
  nix = {
    package = pkgs.nixVersions.stable;
    extraOptions = ''
        experimental-features = nix-command flakes
    '';
  };

  # ISO Image options
  isoImage.squashfsCompression = "gzip -Xcompression-level 1";
  isoImage.isoBaseName = "nixos-surface-installer";
  isoImage.isoName = "${config.isoImage.isoBaseName}-${config.system.nixos.label}-${pkgs.stdenv.hostPlatform.system}.iso";
  isoImage.makeEfiBootable = true;
  isoImage.makeUsbBootable = true;
  isoImage.volumeID = "NIXOS_ISO";

  users.users.Timo.isNormalUser = true;
  users.users.Timo.group = "Timo";
  users.users.Timo.extraGroups = [ "wheel" "networkmanager" "video" "audio" "input" ];
  users.groups.Timo = {};
  users.users.Timo.password = "timo";
}

