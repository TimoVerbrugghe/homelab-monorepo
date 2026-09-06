
# Homelab Kubernetes Cluster on Talos Linux

This folder contains the configuration and resources for managing my personal homelab's Kubernetes cluster, which is deployed on Talos Linux.
Talos Linux is a secure, immutable, and minimal operating system designed specifically for running Kubernetes.

## Installing Talos Linux

Replace IP address below with the IP address of your first node

```bash
talosctl gen secrets

# Generating configs for the controlplane node william
talosctl gen config --output controlplane-william.yaml \
  --output-types controlplane \
  --with-secrets secrets.yaml \
  --config-patch @base-config.yaml \
  --config-patch-control-plane @controlplane-config.yaml \
  --config-patch @william-patch.yaml \
  sectorfive https://10.10.10.30:6443

# Generating configs for the controlplane node skidbladnir
talosctl gen config --output controlplane-skidbladnir.yaml \
  --output-types controlplane \
  --with-secrets secrets.yaml \
  --config-patch @base-config.yaml \
  --config-patch-control-plane @controlplane-config.yaml \
  --config-patch @skidbladnir-patch.yaml \
  sectorfive https://10.10.10.30:6443

# Generating configs for the controlplane node manta
talosctl gen config --output controlplane-manta.yaml \
  --output-types controlplane \
  --with-secrets secrets.yaml \
  --config-patch @base-config.yaml \
  --config-patch-control-plane @controlplane-config.yaml \
  --config-patch @manta-patch.yaml \
  sectorfive https://10.10.10.30:6443

# Generating configs for the worker node yumi
talosctl gen config --output worker-yumi.yaml \
  --output-types worker \
  --with-secrets secrets.yaml \
  --config-patch @base-config.yaml \
  --config-patch @yumi-patch.yaml \
  --config-patch @yumi-patch-localstorage.yaml \
  sectorfive https://10.10.10.30:6443

# Generating talosconfig file
talosctl gen config \
  --with-secrets secrets.yaml \
  --output-types talosconfig \
  -o talosconfig \
  sectorfive https://10.10.10.30:6443

# Applying config to the first controlplane node & then bootstrapping cluster
talosctl apply-config --insecure -n 10.10.10.30 --file controlplane-william.yaml
talosctl bootstrap -n 10.10.10.30 -e 10.10.10.30 --talosconfig talosconfig

# Get kubeconfig file
talosctl kubeconfig --nodes 10.10.10.30 -e 10.10.10.30 --talosconfig ./talosconfig
```

`controlplane-config.yaml` is passed with `--config-patch-control-plane` rather than
`--config-patch`, because `gen config` renders every output type internally and its
`$patch: delete` of the control-plane taint fails against the worker config.

## Updating Existing Nodes

Always regenerate the full config with `talosctl gen config` (as above) and apply it with
`talosctl apply-config --file <file>`. Do **not** use `talosctl patch machineconfig` to move a
node onto these configs: the Talos 1.14 documents (`KubeletConfig`, `UnattendedInstallConfig`,
`SysctlConfig`, `ResolverConfig`, `KubeClusterConfig`, `KubeAPIServerConfig`, `KubeNodeConfig`)
conflict with the equivalent `v1alpha1` fields that a pre-1.14 node still carries, and patching
appends to list fields such as `certSANs`, `addresses`, `routes` and `nameservers` instead of
replacing them.

Test before committing to a change:

```bash
talosctl validate --mode metal --config controlplane-skidbladnir.yaml
talosctl apply-config --dry-run -n 10.10.10.32 --file controlplane-skidbladnir.yaml
# applies in memory and reverts automatically after the timeout
talosctl apply-config --mode=try --timeout=3m -n 10.10.10.32 --file controlplane-skidbladnir.yaml
```

Applying a config always restarts the `kube-apiserver` static pod, so roll one node at a time and
wait for `talosctl get machinestatus` to report `ready: true` before moving on.

## Warning: Kubelet TLS CSR During Bootstrap

During the initial bootstrap the first control plane node may appear unhealthy in Talos
with a kubelet TLS error (see [kubelet-csr diagnostic](https://talos.dev/diagnostic/kubelet-csr)).
This happens because `rotate-server-certificates` is enabled, but the
`kubelet-serving-cert-approver` is not yet running, so the kubelet-serving CSR remains Pending.

Resolution:

1. Deploy the metrics-server (the kubelet-serving-cert-approver is included alongside it in the metrics-server folder).
2. Wait a few seconds for the controller to approve the pending CSR.
3. Re-check node health in Talos; status will report healthy once the serving certificate is issued.

Quick checks:

```bash
kubectl get csr
```

Deploy:

```bash
kubectl apply -k kubernetes/metrics-server/
```

## Adding Additional Nodes

To add more nodes to your Talos cluster, generate the appropriate configuration file for the new node as shown above. Then, apply the configuration to the new node by running:

```bash
talosctl apply-config --insecure -n <NEW_NODE_IP> --file <NEW_NODE_CONFIG>.yaml
```

Replace `<NEW_NODE_IP>` with the IP address of the node you want to add, and `<NEW_NODE_CONFIG>.yaml` with the corresponding configuration file for that node.

## iSCSI volumes

Plex, Jellyfin and Tunarr keep their state on iSCSI volumes served by TrueNAS
(`10.10.10.2:3260`). Those PersistentVolumes still use the **in-tree** `spec.iscsi`
plugin, which Kubernetes has deprecated and Talos 1.14 breaks as soon as workload
isolation (`SecurityProfileConfig` with `workloadIsolation: true`) is enabled: the
kubelet then runs in its own PID namespace and can no longer reach the host `iscsid`.
This repository therefore ships **no** `SecurityProfileConfig` document, and moving
these volumes to a CSI driver (for example
[democratic-csi](https://github.com/democratic-csi/democratic-csi), which has a
first-class TrueNAS ZFS-over-iSCSI driver) is a prerequisite for ever turning
isolation on.

> [!WARNING]
> Plex and Jellyfin store sqlite databases on these volumes and are known to corrupt
> them on NFS-backed storage. Any migration must keep block-level iSCSI semantics.

Deployments that consume these volumes carry the `homelab.io/iscsi-workload: "true"`
label. `.github/workflows/iscsi-kubernetes.yaml` discovers workloads purely by that
label, so they can be scaled down cleanly before a TrueNAS restart and scaled back up
afterwards. Opting a workload in or out is a matter of adding or removing the label —
and it keeps working once the volumes become ordinary CSI-backed PVC references.

## Order of deployment

### Secrets (cloudflare token, tailscale auth token, etc...)

```bash
kubectl apply -k kubernetes/secrets/
```

### Bootstrap cluster

```bash
kubectl kustomize --enable-helm kubernetes/cluster-bootstrap/ | \
  kubectl apply -f -
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
kubectl kustomize --enable-helm kubernetes/<resource>/ | \
  kubectl apply -f -
```
