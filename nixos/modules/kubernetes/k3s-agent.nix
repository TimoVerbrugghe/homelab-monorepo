{ config, pkgs, ... }:

let 
  k3sConfig = ./k3s-agent-config.yaml;
in

{

  imports =[ 
    # Include k3s token key file, you need to put this manually in your nixos install
    /etc/nixos/k3s-token.nix
  ];

  # k3s configuration
  services.k3s = {
    configPath = "${k3sConfig}";
    role = "agent";
    token = "${config.k3stoken}";
    serverAddr = "https://^${config.k3sServerIP}:6443";
  }

}