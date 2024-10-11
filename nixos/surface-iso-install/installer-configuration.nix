# A nix configuration for an autoinstaller ISO (to be used to install on Surface Laptop)

{ config, pkgs, nixpkgs, ... }:

{
  imports =
    [ 
      # Import minimal ISO CD
      (nixpkgs + /nixos/modules/installer/cd-dvd/installation-cd-minimal.nix)

      # Import tools (needed for certain options such as system.nixos-generate-config)
      (nixpkgs + /nixos/modules/installer/tools/tools.nix)

        # Provide an initial copy of the NixOS channel so that the user
      # doesn't need to run "nix-channel --update" first.
      (nixpkgs + /nixos/modules/installer/cd-dvd/channel.nix)
    ];

  # Enable git & sgdisk for partitioning and installing from github flakes later
  environment.systemPackages = with pkgs; [
    nano
    git
    gptfdisk
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

