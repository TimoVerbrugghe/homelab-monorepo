{ config, pkgs, ... }:

let 
  k3sConfig = pkgs.writeText "k3sConfig.yml" ''
    # Setting IPs for pods & services (needed for tailscale routing)
    cluster-cidr: 10.42.0.0/16
    service-cidr: 10.43.0.0/16

    # Disable traefik & servicelb -> Will install traefik manually & using kube-vip
    disable:
    - "traefik"
    - "servicelb"
  '';

  ip_k3s_server = "10.10.10.9";

in

{

  imports =[ 
    # Include k3s token key file, you need to put this manually in your nixos install
    /etc/nixos/k3stoken.nix
  ];

  # k3s configuration
  services.k3s = {
    configPath = "${k3sConfig}";
    role = "agent";
    token = "${config.k3stoken}";
    serverAddr = "https://^${ip_k3s_server}:6443";
  }

}