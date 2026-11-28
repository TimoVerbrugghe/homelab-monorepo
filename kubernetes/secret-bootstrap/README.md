# Bootstrap Secret generators

This Kustomization is a recovery/bootstrap path for the Cloudflare DNS and
tunnel, CrowdSec, Tailscale OAuth, and Traefik Forward Auth credentials. Normal
service Kustomizations do not include it. Its fixed-name generators create
Secrets in `shared-credentials`, and Reflector distributes them to the
explicitly listed consumer namespaces. Other application Secrets are recovered
from Vaultwarden or its backup, not generated here.

Restore the gitignored `*.env` inputs from a protected local backup before
building. The matching `*.env.template` files document the required keys; they
contain no values. Keep the populated files mode `0600`, never commit or print
them, and keep an independent offline recovery copy.

Use this only when bootstrapping or recovering the central source Secrets:

```bash
kubectl apply -k kubernetes/secret-bootstrap/
```

The destination namespaces and Reflector must be available for mirrors to
appear. Do not apply this Kustomization as part of routine service deployment:
it can overwrite rotated Vaultwarden-managed sources with stale local values.

After the controller is ready and the matching bootstrap Login items are in its
`kubernetes-secrets` folder, hand off each bootstrap-created source
`shared-credentials/<name>` explicitly. Delete that source, wait for the
controller to recreate it, and verify the Vaultwarden ownership metadata and
the reflected mirrors before moving to the next Secret. Reflector does not
adopt an existing same-name destination. A source deletion can temporarily
remove automatic mirrors, so perform the handoff in a maintenance window and
confirm each replacement before continuing.

The table inventories all Vaultwarden-managed sources. Only the six
bootstrap-critical sources listed above have generators in this directory.

| Source Secret | Reflected namespaces |
| --- | --- |
| `adguardhome-password` | `adguardhome`, `utilities` |
| `bazarr-api-key` | `mediaplayback`, `utilities` |
| `cloudflare-token-secret` | `cert-manager`, `traefik`, `utilities` |
| `cloudflare-tunnel-token-homelab` | `utilities` |
| `cloudflare-tunnel-token-kubernetes` | `utilities` |
| `crowdsec-secrets` | `crowdsec`, `traefik` |
| `gatus-private-secrets` | `utilities-priv` |
| `homepage-private-secrets` | `utilities` |
| `keel-qbittorrent-credential` | `utilities` |
| `operator-oauth` | `cert-manager`, `tailscale` |
| `plex-claim-token` | `mediaplayback` |
| `plex-token` | `mediaplayback`, `utilities` |
| `pushover-user-key` | `mediaplayback`, `utilities-priv`, `upgrade-notification` |
| `radarr-api-key` | `mediaplayback`, `utilities` |
| `sonarr-api-key` | `mediaplayback`, `utilities` |
| `subgen-private-secrets` | `mediaplayback` |
| `themarr-private-secrets` | `mediaplayback` |
| `traefik-forward-auth-secrets` | `cert-manager`, `traefik` |
| `upgrade-notification-app-token` | `upgrade-notification` |
