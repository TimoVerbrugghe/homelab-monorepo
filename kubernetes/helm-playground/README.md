# Helm Playground

This directory contains a simple Helm chart deployment using Kustomize's native Helm chart support.

## What's Deployed

- **Namespace**: `helm-playground`
- **Helm Chart**: Bitnami NGINX (version 18.2.6)
- **Release Name**: `nginx-playground`

## Features

- Uses Kustomize's built-in Helm chart inflation feature
- Deploys a lightweight NGINX web server from the Bitnami Helm repository
- Configured with minimal resource requests and limits for testing

## Usage

### Deploy

```bash
kubectl apply -k .
```

### Verify Deployment

```bash
kubectl get pods -n helm-playground
kubectl get svc -n helm-playground
```

### Test NGINX

```bash
kubectl port-forward -n helm-playground svc/nginx-playground 8080:80
```

Then visit http://localhost:8080 in your browser.

### Cleanup

```bash
kubectl delete -k .
```

## Customization

To customize the Helm chart values, edit the `valuesInline` section in [kustomization.yaml](kustomization.yaml).

You can also reference the full chart documentation: https://github.com/bitnami/charts/tree/main/bitnami/nginx
