{ config, pkgs, ... }:

{
  ## Boot Configuration
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 3;
  boot.loader.systemd-boot.editor = false;

  # Try to detect BitLocker encrypted drives along with an active TPM. If both are found and Windows Boot Manager is selected in the boot menu, set the “BootNext” EFI variable and restart the system. The firmware will then start Windows Boot Manager directly, leaving the TPM PCRs in expected states so that Windows can unseal the encryption key.
  boot.loader.systemd-boot.rebootForBitlocker = true;
  
  # Reduce swappiness
  boot.kernel.sysctl = { "vm.swappiness" = 20;};

  # Add ability to mount nfs shares
  environment.systemPackages = with pkgs; [ nfs-utils ];
  boot.supportedFilesystems = [ "nfs" ];
  boot.initrd = {
    supportedFilesystems = [ "nfs" ];
    kernelModules = [ "nfs" ];
    verbose = false;
  };

  # Clean /tmp folder on reboot (apparantly false by default)
  boot.tmp.cleanOnBoot = true;

  # Enable plymouth for a nice boot screen
  boot = {

    plymouth = {
      enable = true;
    };

    # Enable "Silent Boot"
    consoleLogLevel = 0;
    kernelParams = [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "loglevel=3"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
    ];

  };

  # Apply kernel patch to fix rust issue with kernel 6.15.9 - https://github.com/NixOS/nixos-hardware/issues/1685
  boot.kernelPatches = [{
    name = "rust-1.91-fix";
    patch = ./rust-fix.patch;
  }];
}