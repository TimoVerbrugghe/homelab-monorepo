{ config, pkgs, ... }:

{
  # Adding default DNS servers
  networking.nameservers = [
    "1.1.1.1"
    "8.8.8.8"
    "8.8.4.4"
  ];
}