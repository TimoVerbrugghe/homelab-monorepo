{ config, pkgs, ... }:

{

  environment.shellAliases = {
    nixupdateboot = "nixos-rebuild boot --flake github:TimoVerbrugghe/homelab-monorepo?dir=nixos#surface --refresh --impure --no-write-lock-file --max-jobs 0";
    nixupdateswitch = "nixos-rebuild switch --flake github:TimoVerbrugghe/homelab-monorepo?dir=nixos#surface --refresh --impure --no-write-lock-file --max-jobs 0";
    nixupdatelocal = "nixos-rebuild boot --flake github:TimoVerbrugghe/homelab-monorepo?dir=nixos#surface --refresh --impure --no-write-lock-file --max-jobs 12 --builders ''";
    nixupdateazure = "nixos-rebuild boot --flake github:TimoVerbrugghe/homelab-monorepo?dir=nixos#surface --refresh --impure --no-write-lock-file --max-jobs 0 --builders 'ssh://remotebuild@azurenixbuilder.azure.timo.be x86_64-linux /root/.ssh/remotebuild 1 1 nixos-test,benchmark,big-parallel,kvm - -'";
    nixupdategamingserver = "nixos-rebuild boot --flake github:TimoVerbrugghe/homelab-monorepo?dir=nixos#surface --refresh --impure --no-write-lock-file --max-jobs 0 --builders 'ssh://remotebuild@gamingserver.local.timo.be x86_64-linux /root/.ssh/remotebuild 1 1 nixos-test,benchmark,big-parallel,kvm - -'";
  };

}