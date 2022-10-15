## Set up prerequisites
apt-get install jq iputils-ping

## Set up k3s cluster
curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE="644" sh -s - server \
  --cluster-init \
  --disable servicelb \
  --disable traefik \
  --tls-san 192.168.0.20

k3sup install \
	--local \
	--cluster \
	--tls-san 192.168.0.20 \
	--k3s-extra-args="--disable servicelb --disable traefik"

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

## Create namespaces for cert-manager & cattle-system
kubectl create namespace cattle-system
kubectl create namespace cert-manager

## Installing helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

## Install cert-manager
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.9.1/cert-manager.crds.yaml

helm install cert-manager jetstack/cert-manager \
 --namespace cert-manager \
 --create-namespace \
 --version v1.9.1 \
 -f /home/timoubuntuserver/HomeServerKubernetes/cert-manager/cert-manager-helm-values.yaml

## Install kubed so that secrets can be synced across all namespaces (f.e. the certificates that cert-manager will generate)
helm repo add appscode https://charts.appscode.com/stable/
helm repo update
helm install kubed appscode/kubed \
  --namespace kube-system

kubectl get deployment --namespace kubed -l "app.kubernetes.io/name=kubed,app.kubernetes.io/instance=kubed"

## Get certificates
kubectl apply \
  -f /home/timoubuntuserver/HomeServerKubernetes/cert-manager/issuers/

## Install traefik
helm repo add traefik https://helm.traefik.io/traefik
helm repo update
helm install traefik traefik/traefik -f /home/timoubuntuserver/HomeServerKubernetes/traefik/traefik-helm-values.yaml

## Install rancher
helm install rancher rancher-stable/rancher \
  --namespace cattle-system \
  --set hostname=ranchertest2.timo.be \
  --set bootstrapPassword=admin

## Check deployment
    kubectl -n cattle-system rollout status deploy/rancher