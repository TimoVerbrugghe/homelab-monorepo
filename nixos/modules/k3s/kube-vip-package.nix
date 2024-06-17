{ stdenv, writeTextFile, curl, containerd, jq, lib, fetchurl }:

let 

  interface = "eth0";
  kube_vip_ip = "10.10.10.40";
  kube_vip_ip_range = "10.10.10.45-10.10.10.50";
  pname = "kube-vip";
  version = "0.8.0";

in

stdenv.mkDerivation rec {
  inherit pname version;

  buildInputs = [ 
    curl
    docker
    jq
  ];

  src = ./.;

  phases = ["buildPhase" "installPhase" "fixupPhase"];

  buildPhase = ''
    # Pull kube-vip image
    docker image pull "ghcr.io/kube-vip/kube-vip:${version}"

    # Generate kube-vip manifest
    docker run --rm --net-host "ghcr.io/kube-vip/kube-vip:${version}" vip /kube-vip manifest daemonset --arp --interface "${interface}" --address "${kube_vip_ip}" --inCluster --taint --controlplane --services --leaderElection | tee $out/kube-vip.yaml
  '';

  installPhase = ''
    runHook preInstall

    # Create manifests directory
    mkdir -p $out/var/lib/rancher/k3s/server/manifests
    mv $out/kube-vip.yaml $out/var/lib/rancher/k3s/server/manifests/kube-vip.yaml

    # Download vip rbac manifest
    curl -sL "https://kube-vip.io/manifests/rbac.yaml" -o $out/var/lib/rancher/k3s/server/manifests/vip-rbac.yaml

    # Download kube-vip cloud controller manifest
    curl -sL "https://raw.githubusercontent.com/kube-vip/kube-vip-cloud-provider/main/manifest/kube-vip-cloud-controller.yaml" -o $out/var/lib/rancher/k3s/server/manifests/kube-vip-cloud-controller.yaml

    # Put kube-vip controlmap in manifests folder
    cat <<EOF > $out/var/lib/rancher/k3s/server/manifests/kube-vip-config.yaml
      apiVersion: v1
      kind: ConfigMap
      metadata:
        name: kubevip
        namespace: kube-system
      data:
        cidr-global: ${kube_vip_ip_range}
    EOF

    runHook postInstall
  '';

  fixupPhase = ''
    chown root:root $out/var/lib/rancher/k3s/server/manifests
    chmod 0644 $out/var/lib/rancher/k3s/server/manifests

    chown root:root $out/var/lib/rancher/k3s/server/manifests/vip-rbac.yaml
    chmod 0644 $out/var/lib/rancher/k3s/server/manifests/vip-rbac.yaml

    chown root:root $out/var/lib/rancher/k3s/server/manifests/kube-vip-cloud-controller.yaml
    chmod 0644 $out/var/lib/rancher/k3s/server/manifests/kube-vip-cloud-controller.yaml

    chown root:root $out/var/lib/rancher/k3s/server/manifests/kube-vip-config.yaml
  '';

  meta = with lib; {
    description = "kube-vip Installer";
    license = licenses.mit;
  };
}
