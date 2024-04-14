{ config, lib, pkgs, ... }:

{
  # Enable input-remapper
  services.input-remapper = {
    enable = true;

    ## Enable built-in udev rules for when Xbox Controller is plugged in/connected through sunshine
    enableUdevRules = true;
  };

  systemd.services.input-remapper.serviceConfig.ExecStart = lib.mkForce "${pkgs.input-remapper}/bin/input-remapper-service -d";

}