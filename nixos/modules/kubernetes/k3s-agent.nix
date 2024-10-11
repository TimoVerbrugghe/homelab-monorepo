{ config, pkgs, ... }:

let 
  k3sConfig = ./k3s-agent-config.yaml;

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