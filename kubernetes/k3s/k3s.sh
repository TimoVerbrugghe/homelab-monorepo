## Installing helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

## Install kubed so that secrets can be synced across all namespaces (f.e. the certificates that cert-manager will generate)
kubectl apply -f ~/HomeServerKubernetes/kubed-deployment.yaml

## Install cert-manager
kubectl apply -f ~/HomeServerKubernetes/cert-manager-deployment.yaml

## Install traefik
kubectl apply -f ~/HomeServerKubernetes/traefik-deployment.yaml

## TEST your cluster deployment here!
kubectl apply -f ~/HomeServerKubernetes/nginx-demo-deployment.yaml

## Install longhorn
kubectl apply -f ~/HomeServerKubernetes/longhorn-deployment.yamll

## Install portainer
kubectl apply -f ~/HomeServerKubernetes/portainer-deployment.yaml