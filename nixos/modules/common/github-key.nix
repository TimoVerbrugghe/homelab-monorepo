{ config, pkgs, ... }:

{
  nix.extraOptions = ''
    !include /etc/nixos/github.key
  '';
}