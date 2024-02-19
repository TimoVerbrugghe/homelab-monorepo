{ config, pkgs, ... }:

let 
  k3sConfig = pkgs.writeText "k3sConfig.yml" ''

  '';

in

{
  # k3s configuration
  services.k3s.configPath = "${k3sConfig}";
  services.k3s.role = "server";
  services.k3s.clusterInit = true;
}

