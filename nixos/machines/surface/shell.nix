{ config, pkgs, ... }:

{

  environment.shellAliases = {
    nixupdateboot = "nixos-rebuild boot --flake github:TimoVerbrugghe/homelab-monorepo?dir=nixos#surface --refresh --impure --no-write-lock-file --max-jobs 0";
    nixupdateswitch = "nixos-rebuild switch --flake github:TimoVerbrugghe/homelab-monorepo?dir=nixos#surface --refresh --impure --no-write-lock-file --max-jobs 0";
    nixupdatelocal = "nixos-rebuild boot --flake github:TimoVerbrugghe/homelab-monorepo?dir=nixos#surface --refresh --impure --no-write-lock-file --max-jobs 12 --builders ''";
    nixupdateazure = "nixos-rebuild boot --flake github:TimoVerbrugghe/homelab-monorepo?dir=nixos#surface --refresh --impure --no-write-lock-file --max-jobs 12 --builders 'ssh://remotebuild@azure.local.timo.be x86_64-linux /root/.ssh/remotebuild 1 1 nixos-test,benchmark,big-parallel,kvm - -'";
  };

  programs.bash = {
    shellInit = '' 
      # Check if the shell is a login shell 
      if [ -n "$BASH_VERSION" ] && [ -z "$SSH_TTY" ]; then
        fastfetch -c /home/Timo/.config/fastfetch/config.jsonc  
      fi 
    '';
  };

}