{ lib, ... }:

with lib;

{
  options = {
    k3stoken = mkOption {
      type = types.str;
      default = "";
      description = "Token used by server and agents for k3s";
    };
  };

  config = {
    k3stoken = ""; # Place randomized common secret here to be used as k3s token
  };
}