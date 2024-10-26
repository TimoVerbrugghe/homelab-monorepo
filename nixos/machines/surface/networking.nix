{ config, pkgs, ... }:

{
  ## Networking setup
  networking.networkmanager.wifi.powersave = true;
  networking.networkmanager.enable = true; # Enable NetworkManager for integration with Gnome/KDE/etc...
  services.avahi.enable = true; # Enable avahi for network discovery
  services.printing.enable = true; # Enable printing services
  services.tailscale.enable = true; # Enable tailscale for VPN

  users.users.Timo.extraGroups = [ "networkmanager" ];

}