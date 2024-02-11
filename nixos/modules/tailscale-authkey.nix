{ lib, ... }:

with lib;

{
  tailscaleAuthKey = mkOption {
    type = types.str;
    default = "";
    description = "Tailscale authentication key";
  };
}