{ config, pkgs, ... }:

{
  # Need to add --install-bootloader because otherwise I'm getting an error when rebuilding nixos that systemd-bootx64.efi & BOOTX64.EFI are skipped due to being the same boot loader version and bootctl giving error, which causes rebuild to error out
  environment.shellAliases = {
    nixupdateboot = "nixos-rebuild boot --flake github:TimoVerbrugghe/homelab-monorepo?dir=nixos#surface --refresh --impure --no-write-lock-file --max-jobs 0 --install-bootloader";
    nixupdateswitch = "nixos-rebuild switch --flake github:TimoVerbrugghe/homelab-monorepo?dir=nixos#surface --refresh --impure --no-write-lock-file --max-jobs 0 --install-bootloader";
    nixupdatelocal = "nixos-rebuild boot --flake github:TimoVerbrugghe/homelab-monorepo?dir=nixos#surface --refresh --impure --no-write-lock-file --max-jobs 12 --builders '' --install-bootloader";
    nixupdateazure = "nixos-rebuild boot --flake github:TimoVerbrugghe/homelab-monorepo?dir=nixos#surface --refresh --impure --no-write-lock-file --max-jobs 0 --builders 'ssh://remotebuild@azurenixbuilder.azure.timo.be x86_64-linux /root/.ssh/remotebuild 1 1 nixos-test,benchmark,big-parallel,kvm - -' --install-bootloader";
    nixupdategamingserver = "nixos-rebuild boot --flake github:TimoVerbrugghe/homelab-monorepo?dir=nixos#surface --refresh --impure --no-write-lock-file --max-jobs 0 --builders 'ssh://remotebuild@gamingserver.local.timo.be x86_64-linux /root/.ssh/remotebuild 1 1 nixos-test,benchmark,big-parallel,kvm - -' --install-bootloader";
  };

}