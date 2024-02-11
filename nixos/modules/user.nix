{ inputs, config, lib, pkgs, ... }:

with lib;
with types;

let
  cfg = config.services.user;
  inherit (inputs) ssh-keys;
in

{

  options.services.user = {
    user = mkOption {
      type = types.str;
    };
    hashedPassword = mkOption {
      type = types.str;
    };
    extragroups = mkOption {
      type = types.listOf types.str;
      default = [ "wheel" "docker" "render" "video" ];
    };
  };

  config = {
    users.mutableUsers = false;

    users.users = {

      ${cfg.user} = {
        extraGroups = cfg.extragroups;
        isNormalUser = true;
        createHome = true;
        hashedPassword = "${cfg.hashedPassword}";
        openssh.authorizedKeys.keyFiles = [ ssh-keys.outPath ];

      };
    };

  };
}