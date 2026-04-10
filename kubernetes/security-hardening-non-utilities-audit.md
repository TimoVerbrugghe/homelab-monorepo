# Security hardening audit (non-utilities namespaces)

## Scope

This audit covers all hardened workload manifests, including `kubernetes/utilities/` and
`kubernetes/utilities-priv/`.

## Security feature matrix

| Workload | Namespace | seccompProfile | allowPrivEsc=false | cap drop ALL | runAsNonRoot | runAsUser/Group | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |
| portainer-backup | portainer | ✅ | ✅ | ❌ | ❌ | ❌ | CronJob; cap drop removed for functionality |
| talos-upgrade-notification | upgrade-notification | ✅ | ✅ | ✅ | ❌ | ❌ | apk add at runtime |
| playground | alpine | ✅ | ✅ | ✅ | ✅ | 65532/65532 | |
| subgen | mediaplayback | ✅ | ✅ | ✅ | ✅ | 3000/3000 | |
| kptv-fast | mediaplayback | ✅ | ✅ | ✅ | ✅ | 3000/3000 | |
| plex-autolanguages | mediaplayback | ✅ | ✅ | ✅ | ✅ | 3000/3000, fsGroup 3000 | emptyDir /config |
| plex | mediaplayback | ✅ | ✅ | ❌ | ❌ | ❌ (env PLEX_UID/GID=3000) | cap drop breaks s6 init |
| jellyfin | mediaplayback | ✅ | ✅ | ✅ | ✅ | 3000/3000, fsGroup 3000 | One-time chown init is currently commented out |
| adguardhome | adguardhome | ✅ | ✅ | ✅ | ❌ | ❌ | Drops ALL + adds NET_BIND_SERVICE |
| netbootxyz | pxeboot | ✅ | ❌ | ❌ | ❌ | ❌ | No container securityContext currently |
| iventoy | pxeboot | ❌ | ❌ | ❌ | ❌ | ❌ | privileged=true by design (PXE/TFTP) |
| keel | utilities | ✅ | ✅ | ✅ | ✅ | ❌ | |
| homepage | utilities | ✅ | ✅ | ✅ | ❌ | ❌ | |
| cloudflared-homelab | utilities | ✅ | ✅ | ✅ | ✅ | ❌ | |
| cloudflared-kubernetes | utilities | ✅ | ✅ | ✅ | ✅ | ❌ | |
| bentopdf | utilities | ✅ | ✅ | ✅ | ❌ | ❌ | seccomp added in this pass |
| tinshop | utilities | ✅ | ✅ | ✅ | ❌ | ❌ | seccomp added in this pass |
| epicgames-freegames | utilities | ✅ | ✅ | ✅ | ❌ | ❌ | seccomp added in this pass |
| ns-usbloader | utilities | ✅ | ✅ | ✅ | ✅ | ✅ (3000/3000) | seccomp added in this pass |
| bitwarden | utilities-priv | ✅ | ✅ | ✅ | ❌ | ❌ | hardened in this pass |
| bitwarden-backup | utilities-priv | ✅ | ✅ | ❌ | ❌ | ❌ | CronJob; cap drop removed for functionality |
| bitwarden-export | utilities-priv | ✅ | ✅ | ❌ | ❌ | ❌ | CronJob; cap drop removed for functionality |
| bitwarden-restore | utilities-priv | ✅ | ✅ | ❌ | ❌ | ❌ | Job; NOT deployed to cluster; kept for manual use only |
| mealie | utilities-priv | ✅ | ✅ | ❌ | ❌ | ❌ | cap-drop reverted (startup chown fails) |
| mealie-backup | utilities-priv | ✅ | ✅ | ❌ | ❌ | ❌ | CronJob; cap drop removed for functionality |
| mealie-restore | utilities-priv | ✅ | ✅ | ❌ | ❌ | ❌ | Job; NOT deployed to cluster; kept for manual use only |
| gatus | utilities-priv | ✅ | ✅ | ✅ | ❌ | ❌ | NET_RAW explicitly added |
| changedetection | utilities-priv | ✅ | ✅ | ✅ | ❌ | ❌ | hardened in this pass |
| playwright-chrome | utilities-priv | ✅ | ✅ | ✅ | ❌ | ❌ | hardened in this pass |

## Notes

- `upgrade-notification` still does not enforce `runAsNonRoot` because both containers run `apk add`
  at runtime.
- `plex` cannot use `capabilities.drop: ["ALL"]` with current image behavior (`s6-applyuidgid`
  needs supplementary group operations).
- `jellyfin` one-time ownership migration init container is currently commented out.
- `mealie` cannot keep `capabilities.drop: ["ALL"]` right now; startup performs `chown` and fails
  with "Operation not permitted" when all caps are dropped.
- For backup/export CronJobs, capability drops were removed because they hindered backup
  functionality (permission issues).
- For restore Jobs, `runAsNonRoot`/`runAsUser` were not enforced because restore operations require
  full access to hostPath/NFS backup data. Restore job manifests are kept in the repository but NOT
  deployed to the cluster to prevent accidental data loss from incomplete or corrupted restore
  operations.

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
