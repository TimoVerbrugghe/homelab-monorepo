
# Homelab Kubernetes Cluster on Talos Linux

This folder contains the configuration and resources for managing my personal homelab's Kubernetes cluster, which is deployed on Talos Linux. Talos Linux is a secure, immutable, and minimal operating system designed specifically for running Kubernetes.

## Installing Talos Linux

Replace IP address below with the IP address of your first node

```bash
talosctl gen secrets

# Generating configs for the controlplane node william
talosctl gen config --output controlplane-william.yaml --output-types controlplane --with-secrets secrets.yaml --config-patch @base-config.yaml --config-patch @william-patch.yaml sectorfive https://10.10.10.30:6443

# Generating configs for the controlplane node skidbladnir
talosctl gen config --output controlplane-skidbladnir.yaml --output-types controlplane --with-secrets secrets.yaml --config-patch @base-config.yaml --config-patch @skidbladnir-patch.yaml sectorfive https://10.10.10.30:6443

# Generating configs for the controlplane node manta
talosctl gen config --output controlplane-manta.yaml --output-types controlplane --with-secrets secrets.yaml --config-patch @base-config.yaml --config-patch @manta-patch.yaml sectorfive https://10.10.10.30:6443

# Generating configs for the worker node yumi2
talosctl gen config --output worker-yumi2.yaml --output-types worker --with-secrets secrets.yaml --config-patch @base-config.yaml --config-patch @yumi2-patch.yaml --config-patch @yumi2-patch-localstorage.yaml sectorfive https://10.10.10.30:6443

# Generating talosconfig file
talosctl gen config --with-secrets secrets.yaml --output-types talosconfig -o talosconfig sectorfive https://10.10.10.30:6443

# Applying config to the first controlplane node & then bootstrapping cluster
talosctl apply-config --insecure -n 10.10.10.30 --file controlplane-william.yaml
talosctl bootstrap -n 10.10.10.30 -e 10.10.10.30 --talosconfig talosconfig
```

## Adding Additional Nodes

To add more nodes to your Talos cluster, generate the appropriate configuration file for the new node as shown above. Then, apply the configuration to the new node by running:

```bash
talosctl apply-config --insecure -n <NEW_NODE_IP> --file <NEW_NODE_CONFIG>.yaml
```

Replace `<NEW_NODE_IP>` with the IP address of the node you want to add, and `<NEW_NODE_CONFIG>.yaml` with the corresponding configuration file for that node.

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

### Configure Traefik

```bash
kubectl apply -k kubernetes/traefik-config/
```

### Deploy other resources

```bash
kubectl apply -k kubernetes/<resource>
```

OR

```bash
kubectl kustomize --enable-helm kubernetes/<resource>/ | kubectl apply -f -
```