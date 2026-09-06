
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
  --config-patch @controlplane-config.yaml \
  --config-patch @william-patch.yaml \
  sectorfive https://10.10.10.30:6443

# Generating configs for the controlplane node skidbladnir
talosctl gen config --output controlplane-skidbladnir.yaml \
  --output-types controlplane \
  --with-secrets secrets.yaml \
  --config-patch @base-config.yaml \
  --config-patch @controlplane-config.yaml \
  --config-patch @skidbladnir-patch.yaml \
  sectorfive https://10.10.10.30:6443

# Generating configs for the controlplane node manta
talosctl gen config --output controlplane-manta.yaml \
  --output-types controlplane \
  --with-secrets secrets.yaml \
  --config-patch @base-config.yaml \
  --config-patch @controlplane-config.yaml \
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

## Upgrading Talos to 1.14

Talos does not support skipping minor versions, so upgrading from 1.12 requires two
hops: **1.12 → 1.13 → 1.14**. Bump the tag on `install.image` in
`talos/base-config.yaml` and re-apply between each hop. The Image Factory schematic ID
is a content hash of `talos/talos-image.yaml`, so it does not change when only the
version tag changes.

### Workload isolation and the in-tree iSCSI volume plugin

Talos 1.14 introduces `sandboxd`: CRI containerd, the kubelet and all pods run in a
dedicated PID and mount namespace. With workload isolation enabled the deprecated
in-tree Kubernetes `iscsi` volume plugin **does not work** — the kubelet can no longer
reach the host `iscsid` across the sandbox PID namespace boundary.

Isolation is **opt-in on upgrade**: `talosctl gen config` only emits a
`SecurityProfileConfig` document with `workloadIsolation: true` for freshly generated
clusters. An upgraded cluster has no such document and keeps the previous non-isolated
behaviour, so the upgrade by itself changes nothing for iSCSI. This repository
deliberately does **not** ship a `SecurityProfileConfig` document.

`mediaplayback/{plex,jellyfin,tunarr}/*-storage.yaml` all use raw `spec.iscsi`
PersistentVolumes against the TrueNAS portal at `10.10.10.2:3260` and are therefore
affected. All in-tree (non-CSI) volume plugins are deprecated for the kubelet and may
be removed in a later Kubernetes release.

Keep `siderolabs/iscsi-tools` in `talos/talos-image.yaml` (it provides the host
`iscsid`) and keep the `-fat` kubelet image in `talos/base-config.yaml` (it ships the
`iscsiadm` wrapper the kubelet shells out to).

### CSI migration roadmap

Migrating to a CSI driver is the real fix: a CSI node plugin performs the attach and
mount itself inside its own privileged pod, so the sandbox boundary is irrelevant.
Because the backing store is a TrueNAS box serving zvols over iSCSI,
[democratic-csi](https://github.com/democratic-csi/democratic-csi) is the natural
choice; `kubernetes-csi/csi-driver-iscsi` is the lighter alternative if the targets
stay hand-managed on TrueNAS.

Outstanding work, to be done in a separate change:

1. Add `kubernetes/democratic-csi/` following the usual Kustomize layout (rendered
   manifests, not `helmCharts:`) with a `<service>-secrets.env.template` for the
   TrueNAS API key / SSH credentials.
2. Replace the three `*-storage.yaml` files: drop the hand-written `PersistentVolume`
   with `spec.iscsi`, point the PVC at the new StorageClass and drop the
   `storageClassName: ""` binding trick. Since the PVs use
   `persistentVolumeReclaimPolicy: Retain`, the existing zvols can be imported as
   pre-provisioned CSI PVs instead of re-copying data.
3. Drop the now-redundant `format-volume` initContainer from `plex.yaml` and siblings —
   CSI formats via `fsType` on the StorageClass.
4. Only once CSI is proven, add a `SecurityProfileConfig` document with
   `workloadIsolation: true`, one node at a time, verifying mounts between nodes.

> [!WARNING]
> Plex and Jellyfin store sqlite databases on these volumes and are known to corrupt
> them on NFS-backed storage. Any migration must preserve block-level iSCSI semantics —
> never let these land on an NFS-backed StorageClass. Snapshot the zvols on TrueNAS
> before cutting over.

The `homelab.io/iscsi-workload: "true"` label on the plex, jellyfin and tunarr
Deployments is what `.github/workflows/iscsi-kubernetes.yaml` uses to discover them; it
is the only signal that survives the CSI migration, after which the volumes become
ordinary PVC references.

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
