{ config, pkgs, ... }:

let 

  fastfetchconfig = pkgs.writeText "fastfetch.conf" ''
    {
      "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
      "modules": [
        "title",
        "separator",
        "os",
        "host",
        "kernel",
        "uptime",
        "display",
        "de",
        "wm",
        "wmtheme",
        "cpu",
        "gpu",
        "memory",
        "disk",
        "localip",
        "battery",
        "poweradapter"
      ]
    }
  '';

in

{

  environment.shellAliases = {
    nixupdateboot = "nixos-rebuild boot --flake github:TimoVerbrugghe/homelab-monorepo?dir=nixos#surface --refresh --impure --no-write-lock-file --max-jobs 0";
    nixupdateswitch = "nixos-rebuild switch --flake github:TimoVerbrugghe/homelab-monorepo?dir=nixos#surface --refresh --impure --no-write-lock-file --max-jobs 0";
    nixupdatelocal = "nixos-rebuild boot --flake github:TimoVerbrugghe/homelab-monorepo?dir=nixos#surface --refresh --impure --no-write-lock-file --max-jobs 12 --builders ''";
  };

  programs.bash = {
    promptInit = ''
      fastfetch --config-file ${fastfetchconfig}
    '';
  };

}