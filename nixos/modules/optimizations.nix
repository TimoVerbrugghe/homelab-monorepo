{ config, pkgs, ... }:

{
  # Nix-store optimizations
  nix.optimise.automatic = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # Increase UDP Buffer size to 25 MB
  boot.kernel.sysctl = { 
    "net.core.rmem_max" = 25000000; 
    "net.core.wmem_max" = 25000000; 
    "net.core.rmem_default" = 25000000;
    "net.core.wmem_default" = 25000000;
  };
}