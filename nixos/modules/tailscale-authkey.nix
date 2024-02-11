{ lib, ... }:

with lib;

{
  options = {
    tailscaleAuthKey = mkOption {
      type = types.str;
      default = "";
      description = "Tailscale authentication key";
    };
  };

  config = {
    tailscaleAuthKey = ""; # Place tailscale Auth Key here
  };
}