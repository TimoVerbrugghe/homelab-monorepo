{ config, pkgs, ... }:

{
  deployment.keys.tailscale-authkey.text = ""; # Put a tailscale authkey in here and place that in /etc/nixos
}