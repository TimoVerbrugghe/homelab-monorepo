{ config, pkgs, ... }:

let 
  k3sConfig = pkgs.writeText "k3sConfig.yml" ''
    cluster-init: true
    tls-san: 
      - kubernetes.local.timo.be
    write-kubeconfig-mode: '644'

    # Setting IPs for pods & services (needed for tailscale routing)
    cluster-cidr: 10.42.0.0/16
    service-cidr: 10.43.0.0/16

    # Disable traefik & servicelb -> Will install traefik manually & using kube-vip
    disable:
    - "traefik"
    - "servicelb"

    kubelet-arg:
    - "feature-gates=GracefulNodeShutdown=true"
    - "node-status-update-frequency=4s"

    kube-controller-manager-arg:
    - "node-monitor-period=4s"
    - "node-monitor-grace-period=16s"

    kube-apiserver-arg:
    - "default-not-ready-toleration-seconds=20"
    - "default-unreachable-toleration-seconds=20" 

    etcd-expose-metrics: true
  '';

in

{
  # k3s configuration
  services.k3s.configPath = "${k3sConfig}";
  services.k3s.role = "server";
  services.k3s.clusterInit = true;
}