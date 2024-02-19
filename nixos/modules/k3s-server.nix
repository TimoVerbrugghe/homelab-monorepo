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

cluster-init:%20true%0Atls-san%3A%20%0A%7B%7B%20tls_san%20%7C%20default(%22%22)%20%7D%7D%0Awrite-kubeconfig-mode%3A%20'644'%0A%0A%23%20Setting%20IPs%20for%20pods%20&%20services%20(needed%20for%20tailscale%20routing)%0Acluster-cidr:%2010.42.0.0/16%0Aservice-cidr:%2010.43.0.0/16%0A%0A%23%20Disable%20traefik%20&%20servicelb%20-%3E%20Will%20install%20traefik%20manually%20&%20using%20kube-vip%0Adisable:%0A-%20%22traefik%22%0A-%20%22servicelb%22%0A%0Akubelet-arg:%0A-%20%22feature-gates=GracefulNodeShutdown=true%22%0A-%20%22node-status-update-frequency=4s%22%0A%0Akube-controller-manager-arg:%0A-%20%22node-monitor-period=4s%22%0A-%20%22node-monitor-grace-period=16s%22%0A%0Akube-apiserver-arg:%0A-%20%22default-not-ready-toleration-seconds=20%22%0A-%20%22default-unreachable-toleration-seconds=20%22%20%0A%0Aetcd-expose-metrics:%20true