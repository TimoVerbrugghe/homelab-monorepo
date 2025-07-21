## Installing Talos Linux

Replace IP address below with the IP address of your first node

```bash
talosctl gen secrets
talosctl gen config --output controlplane-william.yaml --output-types controlplane --with-secrets secrets.yaml --config-patch @base-config.yaml --config-patch @william-patch.yaml --config-patch @extension-patch.yaml sectorfive https://10.10.10.30:6443
talosctl gen config --with-secrets secrets.yaml --output-types talosconfig -o talosconfig sectorfive https://10.10.10.30:6443
talosctl apply-config --insecure -n 10.10.10.30 --file controlplane-william.yaml
talosctl bootstrap -n 10.10.10.30 -e 10.10.10.30 --talosconfig talosconfig
```

## Order of deployment

### Secrets (cloudflare token, tailscale auth token, etc...)

```bash
kubectl apply -k kubernetes/secrets/
```

### Bootstrap cluster

```bash
kubectl kustomize --enable-helm kubernetes/cluster-bootstrap/ | kubectl apply -f -
```

### Generate certificates

```bash
kubectl apply -k kubernetes/cert-manager/
```

### Configure Traefik & authentication

```bash
kubectl apply -k kubernetes/traefik-config/
```

### Deploy other resources

```bash
kubectl kustomize --enable-helm kubernetes/utilities/ | kubectl apply -f -
```
