{ config, pkgs, ... }:

{
  # Nix-store optimizations
  nix.optimise.automatic = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # Increase download buffer size
  nix.settings.download-buffer-size = 524288000;
}