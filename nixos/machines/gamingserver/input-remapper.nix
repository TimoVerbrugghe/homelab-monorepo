{ config, lib, pkgs, ... }:

{
  # Enable input-remapper
  services.input-remapper = {
    enable = true;

    ## Enable built-in udev rules for when Xbox Controller is plugged in/connected through sunshine
    enableUdevRules = true;
  };

}