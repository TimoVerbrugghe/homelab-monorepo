{ config, lib, pkgs, ... }:

{
  # Enable input-remapper
  services.input-remapper = {
    enable = true;

    ## Enable built-in udev rules for when Xbox Controller is plugged in/connected through sunshine
    enableUdevRules = true;
  };

  # Overriding input-remapper systemd service with debug flag (using method mentioned in https://github.com/NixOS/nixpkgs/issues/63703)
  # systemd.services.input-remapper.serviceConfig.ExecStart = [
  #   ""
  #   "${pkgs.input-remapper}/bin/input-remapper-service -d"
  # ]; 

}