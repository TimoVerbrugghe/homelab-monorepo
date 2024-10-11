{ config, pkgs, ... }:

let 
  k3sConfig = ./k3s-server-config.yaml;

  kubeVipRbac = builtins.fetchurl {
    url = "https://kube-vip.io/manifests/rbac.yaml";
    sha256 = ""; # sha256sum of the file can change due to updates to the rbac
  };

  kubeVipCloudController = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/kube-vip/kube-vip-cloud-provider/main/manifest/kube-vip-cloud-controller.yaml";
    sha256 = ""; # sha256sum of the file can change due to updates to the cloud-controller
  };

  kubeVipConfigmap = ./kube-vip-configmap.yaml;

  kubeVipManifest = ./kube-vip-manifest.yaml;

in

{

  imports =[ 
    # Include k3s token key file, you need to put this manually in your nixos install
    /etc/nixos/k3stoken.nix
  ];

  # k3s configuration
  services.k3s = {
    configPath = "${k3sConfig}";
    role = "server";
    clusterInit = true;
    token = "${config.k3stoken}";
    manifests = [
      {
        source = kubeVipRbac;
        target = "kube-vip-rbac.yaml";
      }
      {
        source = kubeVipCloudController;
        target = "kube-vip-cloud-controller.yaml";
      }
      {
        source = kubeVipConfigmap;
        target = "kube-vip-configmap.yaml";
      }
      {
        source = kubeVipManifest;
        target = "kube-vip.yaml";
      }
    ];

    }
  };

}