{ config, pkgs, ... }:

{
  imports =
    [ 
      (nixpkgs + "/nixos/modules/profiles/qemu-guest.nix")
    ];

  # Enable QEMU guest agent for better VM integration
  services.qemuGuest.enable = true;
  
  # Enable watchdog
  systemd.watchdog.device = "/dev/watchdog";
  systemd.watchdog.runtimeTime = "30s";
}