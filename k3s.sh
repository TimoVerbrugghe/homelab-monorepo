## Set up k3s cluster
curl -sfL https://get.k3s.io | sh -s - server --cluster-init --write-kubeconfig-mode 644 --disable traefik --disable servicelb

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