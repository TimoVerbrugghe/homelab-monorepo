## Set up prerequisites
apt-get install jq

## Set up k3s cluster
k3sup install \
	--host=timoubuntuserver \
	--user=root \
	--cluster \
	--tls-san 192.168.0.20 \
	--k3s-extra-args="--disable servicelb --disable traefik"

## Install kube-vip
## See https://kube-vip.io/docs/installation/daemonset/#kube-vip-as-ha-load-balancer-or-both for updated instructions on how to install as daemonset

## Generate kube-vip manifest
kube-vip manifest daemonset \
    --arp \
    --interface $INTERFACE \
    --address $VIP \
    --inCluster \
    --taint \
    --controlplane \
    --leaderElection | tee /var/lib/rancher/k3s/server/manifests/kube-vip.yaml

## Make sure kubeconfig is in the user home folder
kubectl config view --raw >~/.kube/config

## Create namespaces for cert-manager & cattle-system
kubectl create namespace cattle-system
kubectl create namespace cert-manager

## Install cert-manager
helm install   cert-manager jetstack/cert-manager   --namespace cert-manager   --create-namespace   --version v1.9.1

## Install rancher
helm install rancher rancher-stable/rancher \
  --namespace cattle-system \
  --set hostname=ranchertest2.timo.be \
  --set bootstrapPassword=admin

## Check deployment
    kubectl -n cattle-system rollout status deploy/rancher