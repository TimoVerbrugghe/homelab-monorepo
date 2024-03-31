{ config, pkgs, ... }:

{

  ### Install Dependencies ###
  environment.systemPackages = with pkgs; [
    containerd
    kubernetes-helm
    kubectl
  ];

  # Enable ipv4/ipv6 forwarding & ipv6 router advertisements
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
    "net.ipv6.conf.all.accept_ra" = 2; 
  };

  # k3s configuration
  services.k3s.enable = true;

  networking.firewall.allowedTCPPorts = [
    6443 # k3s: required so that pods can reach the API server (running on port 6443 by default)
    2379 # k3s, etcd clients: required if using a "High Availability Embedded etcd" configuration
    2380 # k3s, etcd peers: required if using a "High Availability Embedded etcd" configuration
  ];
}