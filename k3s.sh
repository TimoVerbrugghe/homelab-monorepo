## Set up prerequisites
apt-get install jq iputils-ping nfs-common

## Set up k3s cluster
curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE="644" sh -s - server \
  --cluster-init \
  --disable servicelb \
  --disable traefik \
  --tls-san 192.168.0.20

## Install kube-vip
## See https://kube-vip.io/docs/installation/daemonset/#kube-vip-as-ha-load-balancer-or-both for updated instructions on how to install as daemonset

export INTERFACE=enp1s0
export VIP=192.168.0.20
KVVERSION=$(curl -sL https://api.github.com/repos/kube-vip/kube-vip/releases | jq -r ".[0].name")
alias kube-vip="ctr image pull ghcr.io/kube-vip/kube-vip:$KVVERSION; ctr run --rm --net-host ghcr.io/kube-vip/kube-vip:$KVVERSION vip /kube-vip"

## Install kube-vip RBAC
kubectl apply -f https://kube-vip.io/manifests/rbac.yaml

## Generate kube-vip manifest
kube-vip manifest daemonset \
    --arp \
    --interface $INTERFACE \
    --address $VIP \
    --inCluster \
    --taint \
    --controlplane \
    --leaderElection | tee /var/lib/rancher/k3s/server/manifests/kube-vip.yaml

## Install metallb
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.6/config/manifests/metallb-native.yaml
kubectl apply -f /home/timoubuntuserver/HomeServerKubernetes/metallb/resources.yaml

## Installing helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

## Install kubed so that secrets can be synced across all namespaces (f.e. the certificates that cert-manager will generate)
kubectl apply -f /home/timoubuntuserver/HomeServerKubernetes/kubed/kubed-deployment.yaml

## Install cert-manager
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.9.1/cert-manager.crds.yaml
kubectl apply -f /home/timoubuntuserver/HomeServerKubernetes/cert-manager/cert-manager-deployment.yaml

# check deployment
kubectl get deployment --namespace kube-system -l "app.kubernetes.io/name=kubed,app.kubernetes.io/instance=kubed"

## Get certificates
kubectl apply -f /home/timoubuntuserver/HomeServerKubernetes/cert-manager/secrets
kubectl apply -f /home/timoubuntuserver/HomeServerKubernetes/cert-manager/certificates

## Install traefik
kubectl apply -f /home/timoubuntuserver/HomeServerKubernetes/traefik/traefik-deployment.yaml

## TEST your cluster deployment here!
kubectl apply -f /home/timoubuntuserver/HomeServerKubernetes/nginx-demo/nginx-demo-deployment.yaml

## Install longhorn
kubectl apply -f /home/timoubuntuserver/HomeServerKubernetes/longhorn/longhorn-deployment.yaml

## Install rancher
kubectl apply -f /home/timoubuntuserver/HomeServerKubernetes/rancher/rancher-deployment.yaml

## Check deployment
kubectl -n cattle-system rollout status deploy/rancher
