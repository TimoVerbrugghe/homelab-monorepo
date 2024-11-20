{ lib, ... }:

with lib;

{
  options = {
    k3stoken = mkOption {
      type = types.str;
      default = "";
      description = "Token used by server and agents for k3s";
    };

    k3sServerIP = mkOption {
      type = types.str;
      default = "";
      description = "IP address of the initial k3s server";
  };

  config = {
    k3stoken = ""; # Place randomized common secret here to be used as k3s token
    k3sServerIP = "10.10.10.9"; # Place the IP address of the initial k3s server here
  };
}