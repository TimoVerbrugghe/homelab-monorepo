
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
(`10.10.10.2:3260`). The **in-tree** `spec.iscsi` plugin these used to rely on is
deprecated by Kubernetes and broken by Talos 1.14 workload isolation
(`SecurityProfileConfig` with `workloadIsolation: true`, now enabled on every node): the
kubelet then runs in its own PID namespace and can no longer reach the host `iscsid`.
Those PersistentVolumes now use `spec.csi` against
[democratic-csi](https://github.com/democratic-csi/democratic-csi) instead — see
`kubernetes/democratic-csi/`, installed from its Helm chart through Kustomize's
`helmCharts:`. The driver runs in **`node-manual`** mode: it only performs the
node-side attach/mount of volumes that already exist on TrueNAS, so it needs no
TrueNAS API key and no controller — its entire config is `driver: node-manual`,
inline in `democratic-csi-values.yaml`. Targets stay hand-managed on TrueNAS
exactly as before; the PVs carry the portal, IQN and LUN.

On Talos, `iscsid` runs as the `ext-iscsid` extension service in its own mount
namespace, so the node plugin is configured with `ISCSIADM_HOST_STRATEGY: chroot` and
`ISCSIADM_HOST_PATH: /usr/local/sbin/iscsiadm`. Every `iscsiadm` call therefore runs as
`chroot /host /usr/local/sbin/iscsiadm`, using the host's own `/etc/iscsi` and
`/var/lib/iscsi` through the chart's `/` hostPath, and reaches `iscsid` over its
netns-scoped socket because the pod has `hostNetwork: true`.

The alternative `nsenter` strategy must **not** be used here. It locates `iscsid` with
`pgrep iscsid` and enters its namespaces, but under `workloadIsolation: true` `hostPID`
only exposes the sandbox's PID namespace (PID 1 is `sandboxd`), so `pgrep` finds nothing
and every `iscsiadm` call fails.

Do **not** hostPath-mount `/etc/iscsi` or `/var/lib/iscsi` into the node plugin: they
exist in the Talos host root but not in the kubelet's mount namespace, where hostPath
volumes are resolved, so the pods would never leave `ContainerCreating`.

`kubernetes-csi/csi-driver-iscsi` was evaluated as an alternative — Talos names it
first in the 1.14 release notes — but it is self-declared **Alpha**, has no tagged
release, no Helm chart, and is published only as
`gcr.io/k8s-staging-sig-storage/iscsiplugin:canary`, so it cannot be pinned.

`base-config.yaml` sets `workloadIsolation: true`. The setting only takes effect when
the affected services start, so `talosctl patch mc` alone is not enough despite its
`Applied configuration without a reboot` message — reboot each node afterwards, one at a
time, and confirm a `sandboxd` service appears in `talosctl -n <ip> services`.

> [!WARNING]
> Plex and Jellyfin store sqlite databases on these volumes and are known to corrupt
> them on NFS-backed storage. Any migration must keep block-level iSCSI semantics.

### Cutting a volume over to CSI

`spec.persistentvolumesource` on a PV and `spec.storageClassName` on a PVC are both
immutable, so `kubectl apply` cannot convert an existing volume in place — the pair has
to be recreated. The reclaim policy is `Retain`, so deleting them never touches the
zvol, and democratic-csi only formats a device that is not already formatted, so the
existing ext4 filesystem and its data survive untouched. Snapshot the zvols on TrueNAS
first anyway.

```bash
kubectl -n mediaplayback scale deployment/<service> --replicas=0
kubectl -n mediaplayback delete pvc <service>-pvc
kubectl delete pv <service>-pv
kubectl apply -k kubernetes/mediaplayback/<service>/
kubectl -n mediaplayback rollout status deployment/<service>
```

Deployments that consume these volumes carry the `homelab.io/iscsi-workload: "true"`
label. `.github/workflows/iscsi-kubernetes.yaml` discovers workloads purely by that
label, so they can be scaled down cleanly before a TrueNAS restart and scaled back up
afterwards. Opting a workload in or out is a matter of adding or removing the label —
and it keeps working once the volumes become ordinary CSI-backed PVC references.

## CrowdSec

`kubernetes/crowdsec/` deploys the official `crowdsecurity/crowdsec` Helm chart
alongside Traefik, and Traefik enforces its ban decisions via the
[Traefik CrowdSec bouncer plugin](https://github.com/maxlerebourg/crowdsec-bouncer-traefik-plugin)
on the `websecure` entrypoint. See [`kubernetes/crowdsec/README.md`](crowdsec/README.md)
for the full architecture, the bouncer API key setup, and collections notes.

> [!IMPORTANT]
> Deploy `kubernetes/crowdsec/` and create the bouncer secret **before** the
> `crowdsec-bouncer` middleware is referenced on Traefik's `websecure` entrypoint — see
> [Order of deployment](#order-of-deployment).

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

### Deploy the iSCSI CSI driver

Required before any of the mediaplayback services. No prerequisites — the driver
runs in `node-manual` mode and needs no credentials.

```bash
kubectl kustomize --enable-helm kubernetes/democratic-csi/ | \
  kubectl apply -f -
```

### Deploy CrowdSec (after Traefik's namespace exists)

The `crowdsec-bouncer-secrets` Secret must be reflected into the `traefik` namespace
before the `crowdsec-bouncer` middleware is referenced on Traefik's `websecure`
entrypoint, otherwise Traefik fails to mount the bouncer key file and its pods
`CrashLoopBackOff`. See [`kubernetes/crowdsec/README.md`](crowdsec/README.md) for the
full flow.

```bash
# generate a static key and store it in kubernetes/crowdsec/crowdsec-bouncer.env:
openssl rand -hex 32

kubectl kustomize --enable-helm kubernetes/crowdsec/ | \
  kubectl apply -n crowdsec -f -

kubectl kustomize --enable-helm kubernetes/traefik/ | \
  kubectl apply -f -
kubectl apply -k kubernetes/traefik/middlewares/
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
