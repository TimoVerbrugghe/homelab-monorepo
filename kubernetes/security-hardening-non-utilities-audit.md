# Security hardening audit (non-utilities namespaces)

## Scope

This audit covers all hardened workload manifests, including `kubernetes/utilities/` and
`kubernetes/utilities-priv/`.

## Security feature matrix

| Workload | Namespace | seccompProfile | allowPrivEsc=false | cap drop ALL | runAsNonRoot | readOnlyRootFilesystem | tty/stdin disabled | /tmp isolated | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| portainer-backup | portainer | ✅ | ✅ | ❌ | ❌ | ✅ | ✅ | ❌ | CronJob; cap drop removed for functionality |
| talos-upgrade-notification | upgrade-notification | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | Existing `/tmp` emptyDir kept and size-limited |
| playground | alpine | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ | |
| subgen | mediaplayback | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ | Existing transcode `emptyDir` kept |
| kptv-fast | mediaplayback | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ | |
| plex-autolanguages | mediaplayback | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ | Existing `/config` emptyDir kept |
| plex | mediaplayback | ✅ | ✅ | ✅ | ❌ | ❌ | ✅ | ❌ | Existing memory-backed `/dev/shm` preserved; non-root + readOnly rootfs incompatible with current image startup |
| jellyfin | mediaplayback | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ | Existing memory-backed `/dev/shm` preserved; commented one-time init unchanged |
| adguardhome | adguardhome | ✅ | ✅ | ✅ | ❌ | ✅ | ✅ | ❌ | Drops ALL + adds NET_BIND_SERVICE |
| netbootxyz | pxeboot | ✅ | ✅ | ✅ | ❌ | ❌ | ✅ | ❌ | Existing memory-backed config/assets volumes kept; current image needs writable root filesystem |
| iventoy | pxeboot | ✅ | ❌ | ✅ | ❌ | ❌ | ✅ | ❌ | privileged=true by design (PXE/TFTP); allowPrivilegeEscalation cannot be false while privileged=true; current image needs writable root filesystem |
| keel | utilities | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ | |
| homepage | utilities | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ | |
| cloudflared-homelab | utilities | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | |
| cloudflared-kubernetes | utilities | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | |
| bentopdf | utilities | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ | nginx user |
| tinshop | utilities | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ | Existing app data `emptyDir` kept |
| epicgames-freegames | utilities | ✅ | ✅ | ✅ | ❌ | ❌ | ✅ | ❌ | runAsNonRoot/readOnlyRootFilesystem remain incompatible |
| ns-usbloader | utilities | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ | |
| bitwarden | utilities-priv | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ | Commented one-time chown init left untouched |
| bitwarden-backup | utilities-priv | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ | CronJob hardened with non-root + drop ALL |
| bitwarden-export | utilities-priv | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ | Existing writable config `emptyDir` kept |
| bitwarden-restore | utilities-priv | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ | Manual restore job kept in git only; not deployed |
| mealie | utilities-priv | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ | One-time chown init retained |
| mealie-backup | utilities-priv | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ | CronJob hardened with non-root + drop ALL |
| mealie-restore | utilities-priv | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ | Manual restore job kept in git only; not deployed |
| gatus | utilities-priv | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ | NET_RAW explicitly added |
| changedetection | utilities-priv | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ | Existing data volume kept |
| playwright-chrome | utilities-priv | ✅ | ✅ | ✅ | ✅ | ❌ | ✅ | ❌ | Chrome still excludes readOnlyRootFilesystem |

## Notes

### Manifest-scoped equivalents used here

- `tty/stdin disabled` means each workload container and applicable initContainer explicitly sets `stdin: false` and `tty: false` in the pod spec.
- `/tmp isolated` means the workload already had a dedicated `/tmp` backed by `emptyDir`, and that existing volume was kept with `sizeLimit: 512Mi` when needed.
- Existing memory-backed `/dev/shm` volumes were preserved as-is. No new `/tmp` mount was introduced.

### Kubernetes limitations and scope boundaries

- Standard Kubernetes pod specs do not expose per-mount `noexec`, `nosuid`, or `nodev` flags for normal container volume mounts, so those controls cannot be represented honestly in these manifests.
- Log rotation and log size limiting are node or container-runtime controls, typically configured through kubelet and the runtime.
- They are not workload-scoped manifest controls, so they are documented here rather than added as a per-workload matrix column.

### Existing workload-specific caveats preserved

- `epicgames-freegames` still cannot use `runAsNonRoot` or `readOnlyRootFilesystem` with the current image behavior.
- `plex` still cannot use `runAsNonRoot` or `readOnlyRootFilesystem` with the current image behavior.
- `bitwarden-restore` and `mealie-restore` remain manual restore job manifests kept in git and not intended for deployment by default.
- `netbootxyz` and `iventoy` required `readOnlyRootFilesystem` to be reverted after rollout verification exposed startup writes in the current images.
- `iventoy` cannot set `allowPrivilegeEscalation: false` while `privileged: true` is required by current image behavior.
- `jellyfin` retains its commented one-time ownership migration init container.

## Deferred overlays

These are overlay patches for operator/third-party workloads and were intentionally not
force-hardened at overlay level:

- `kubernetes/cluster-bootstrap/cert-manager/cert-manager-cainjector-patch.yaml`
- `kubernetes/cluster-bootstrap/cert-manager/cert-manager-patch.yaml`
- `kubernetes/cluster-bootstrap/cert-manager/cert-manager-webhook-patch.yaml`
- `kubernetes/cluster-bootstrap/kube-vip/kube-vip-cloud-provider-patch.yaml`
- `kubernetes/cluster-bootstrap/reflector/reflector-patch.yaml`
- `kubernetes/metrics-server/kubelet-serving-cert-approver-patch.yaml`
- `kubernetes/metrics-server/metrics-server-patch.yaml`
- `kubernetes/portainer-agent/portainer-agent-patch.yaml`
- `kubernetes/tailscale/tailscale-operator-patch-deployment.yaml`
- `kubernetes/traefik/traefik-deployment-patch.yaml`

Deferred rationale:

- Drift risk with upstream chart/operator updates
- Potential behavior regressions in control-plane components
- Need rendered-manifest audit (`kubectl kustomize ...`) for accurate final posture
