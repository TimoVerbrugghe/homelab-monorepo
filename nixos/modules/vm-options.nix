{ config, pkgs, nixpkgs, ... }:

{
  imports =
    [ 
      (nixpkgs + /nixos/modules/profiles/qemu-guest.nix)
    ];
    
  # Enable QEMU guest agent for better VM integration
  services.qemuGuest.enable = true;
  
  # Enable watchdog
  systemd.settings.Manager = {
    RuntimeWatchdogSec = "30s";
    WatchdogDevice = "/dev/watchdog";
  };

  # Enable fstrim so that discarded blocks are recovered on the host
  services.fstrim.enable = true;

  # Enable serial console so that I can access console in proxmox
  boot.kernelParams = [ "console=tty0" "console=ttyS0,115200" ];
}