#!/bin/sh

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <tailscaleauthkey> <nixosFlake>"
  exit 1
fi

tailscaleauthkey="$1"
nixosFlake="$2"

# Create tailscale-authkey.nix file
cat > /etc/nixos/tailscale-authkey.nix << EOF
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
    tailscaleAuthKey = "$tailscaleauthkey";
  };
}
EOF

# Run nixos-rebuild command
nixos-rebuild boot --flake "github:TimoVerbrugghe/homelab-monorepo?dir=nixos#$nixosFlake" --refresh --impure --no-write-lock-file
