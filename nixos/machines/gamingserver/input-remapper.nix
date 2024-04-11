{ config, pkgs, ... }:

{
  # Enable input-remapper
  services.input-remapper.enable = true;

  ## TO DO: Need to write udev rule for when Xbox controller gets plugged in
  ## TO DO: Need to write systemd service for autoload of input-remapper
  
}