#!/bin/bash

# Default values
tailscaleauthkey=""
nixosFlake=""

# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --tailscaleauthkey)
            tailscaleauthkey="$2"
            shift 2
            ;;
        --nixosFlake)
            nixosFlake="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Check if required arguments are provided
if [ -z "$tailscaleauthkey" ] || [ -z "$nixosFlake" ]; then
    echo "Usage: $0 --tailscaleauthkey <tailscaleauthkey> --nixosFlake <nixosFlake>"
    exit 1
fi

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
