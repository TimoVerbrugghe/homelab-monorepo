## Set up prerequisites
apt-get install jq iputils-ping nfs-common git

git config --global user.email ""
git config --global user.name "Timo Verbrugghe"

## Copy over config.yaml
mkdir -p /etc/rancher/k3s
mkdir -p /var/lib/scheduler
cp k3s/k3sserverconfig.yaml /etc/rancher/k3s/config.yaml
cp scheduler-config.yaml /var/lib/scheduler/scheduler-config.yaml

## Set up k3s cluster
curl -sfL https://get.k3s.io | sh -

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
    --services \
    --leaderElection | tee /var/lib/rancher/k3s/server/manifests/kube-vip.yaml

kubectl apply -f https://raw.githubusercontent.com/kube-vip/kube-vip-cloud-provider/main/manifest/kube-vip-cloud-controller.yaml
kubectl create configmap -n kube-system kubevip --from-literal range-global=192.168.0.30-192.168.0.40

## Installing helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

## Install kubed so that secrets can be synced across all namespaces (f.e. the certificates that cert-manager will generate)
kubectl apply -f ~/HomeServerKubernetes/kubed-deployment.yaml

## Install secrets
kubectl apply -f ~/HomeServerKubernetes/secrets.yaml

## Install cert-manager
kubectl apply -f ~/HomeServerKubernetes/cert-manager-deployment.yaml

## Install traefik
kubectl apply -f ~/HomeServerKubernetes/traefik-deployment.yaml

## TEST your cluster deployment here!
kubectl apply -f ~/HomeServerKubernetes/nginx-demo-deployment.yaml

## Install longhorn
kubectl apply -f ~/HomeServerKubernetes/longhorn-deployment.yamll

## Install rancher
kubectl apply -f ~/HomeServerKubernetes/portainer-deployment.yaml

## Check deployment
kubectl -n cattle-system rollout status deploy/rancher
