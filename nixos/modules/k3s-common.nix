{ config, pkgs, ... }:

{

  ### Install Dependencies ###
  environment.systemPackages = with pkgs; [
    containerd
    kubernetes-helm
  ];

  # Enable ipv4/ipv6 forwarding & ipv6 router advertisements
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
    "net.ipv6.conf.all.accept_ra" = 2; 
  };

  # k3s configuration
  services.k3s.enable = true;
}