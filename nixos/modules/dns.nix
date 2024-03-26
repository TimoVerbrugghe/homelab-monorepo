{ config, pkgs, ... }:

{
  # Adding default DNS servers
  networking.nameservers = [
    "10.10.10.20"
    "10.10.10.21"
    "10.10.10.22"
  ];
}