{ config, pkgs, ... }:

let 

  interface = "eth0";
  kube_vip_ip = "10.10.10.40";
  kube_vip_ip_range = "10.10.10.45-10.10.10.50";

in

{

  # Define the activation script
  systemd.services.kube-vip-installation = {
    enable = true;
    description = "Kube-VIP installation script";
    wantedBy = [ "multi-user.target" ];
    after = ["network-online.target"];
    wants = ["network-online.target"];
    path = with pkgs; [
      containerd
      curl
    ];
    script = ''
      # Check if vip-rbac.yaml already exists
      if [ -f "/var/lib/rancher/k3s/server/manifests/vip-rbac.yaml" ]; then
          echo "vip-rbac.yaml already exists. Skipping the rest of the script."
      else
          # Create manifests directory
          mkdir -p /var/lib/rancher/k3s/server/manifests
          chown root:root /var/lib/rancher/k3s/server/manifests
          chmod 0644 /var/lib/rancher/k3s/server/manifests

          # Get latest kube-vip version from GitHub
          kvversion=$(curl -sL https://api.github.com/repos/kube-vip/kube-vip/releases | jq -r '.[0].name')

          # Download vip rbac manifest
          curl -sL "https://kube-vip.io/manifests/rbac.yaml" -o "/var/lib/rancher/k3s/server/manifests/vip-rbac.yaml"
          chown root:root "/var/lib/rancher/k3s/server/manifests/vip-rbac.yaml"
          chmod 0644 "/var/lib/rancher/k3s/server/manifests/vip-rbac.yaml"

          # Download kube-vip cloud controller manifest
          curl -sL "https://raw.githubusercontent.com/kube-vip/kube-vip-cloud-provider/main/manifest/kube-vip-cloud-controller.yaml" -o "/var/lib/rancher/k3s/server/manifests/kube-vip-cloud-controller.yaml"
          chown root:root "/var/lib/rancher/k3s/server/manifests/kube-vip-cloud-controller.yaml"
          chmod 0644 "/var/lib/rancher/k3s/server/manifests/kube-vip-cloud-controller.yaml"

          # Pull kube-vip image
          ctr image pull "ghcr.io/kube-vip/kube-vip:$kvversion"

          # Generate kube-vip manifest
          ctr run --rm --net-host "ghcr.io/kube-vip/kube-vip:$kvversion" vip /kube-vip manifest daemonset --arp --interface "${interface}" --address "${kube_vip_ip}" --inCluster --taint --controlplane --services --leaderElection | tee "/var/lib/rancher/k3s/server/manifests/kube-vip.yaml"

          # Put kube-vip controlmap in manifests folder
          cat <<EOF > "/var/lib/rancher/k3s/server/manifests/kube-vip-config.yaml"
            apiVersion: v1
            kind: ConfigMap
            metadata:
              name: kubevip
              namespace: kube-system
            data:
              cidr-global: ${kube_vip_ip_range}
          EOF
          chown root:root "/var/lib/rancher/k3s/server/manifests/kube-vip-config.yaml"
      fi
    '';
  };

}