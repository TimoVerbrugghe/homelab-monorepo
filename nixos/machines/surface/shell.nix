{ config, pkgs, ... }:

{

  environment.shellAliases = {
    nixupdateboot = "nixos-rebuild boot --flake github:TimoVerbrugghe/homelab-monorepo?dir=nixos#surface --refresh --impure --no-write-lock-file --max-jobs 0";
    nixupdateswitch = "nixos-rebuild switch --flake github:TimoVerbrugghe/homelab-monorepo?dir=nixos#surface --refresh --impure --no-write-lock-file --max-jobs 0";
    nixupdatelocal = "nixos-rebuild boot --flake github:TimoVerbrugghe/homelab-monorepo?dir=nixos#surface --refresh --impure --no-write-lock-file --max-jobs 12 --builders ''";
  };

  programs.bash = {
    loginShellInit = ''
      fastfetch
    '';
  };

}