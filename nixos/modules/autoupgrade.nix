{ inputs, config, lib, pkgs, ... }:

with lib;
with types;

let
  cfg = config.services.autoUpgrade;
in

{

  options.services.autoUpgrade = {
    hostname = mkOption {
      type = types.str;
    };
  };

  config = {
    system.autoUpgrade = {
      enable = true;
      flake = "github:TimoVerbrugghe/homelab-monorepo?dir=nixos#${cfg.hostname}";
      flags = [
        "--update-input"
        "nixpkgs"
        "--no-write-lock-file"
        "--refresh" # so that latest commits to github repo get downloaded
        "--impure" # needed because I'm referencing a file with variables locally on the system, have to find a better way to deal with secrets
      ];
      dates = "05:00";
      randomizedDelaySec = "45min";
    };
  };
}