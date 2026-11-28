# Vaultwarden Kubernetes Secrets

See the [migration guide](migration.md) for the source inventory, cutover and
recovery procedures.

## Status

The sync Deployment runs in `utilities` and writes fixed-name source Secrets
only in `shared-credentials`. Reflector copies each source Secret to the
consumer namespaces allowed by its Vaultwarden Login. The combined
`recyclarr-secrets` Login has been retired; Recyclarr now consumes the separate
reflected Sonarr and Radarr credentials.

The active controller Role is namespace-scoped to `shared-credentials`.
Reflector remains the cluster-wide Secret distribution dependency. The
separate `kubernetes/secret-bootstrap/` Kustomization retains fixed-name
generators for bootstrap-critical credentials, but is not part of routine
service deployment and can overwrite newer Vaultwarden data if reapplied.

This is a plain Kustomize deployment of the
[upstream project](https://github.com/antoniolago/vaultwarden-kubernetes-secrets).
Helm, CRDs, and PVCs are not required. The sync worker and API share a
memory-backed `emptyDir` for SQLite and cache; the dashboard runs separately.
Restarting the sync pod loses history/cache, not vault items or Kubernetes
Secrets. Automatic orphan deletion is disabled and RBAC grants no delete
permission. Use one sync replica with `Recreate` to avoid concurrent reconcilers.

The container uses UID/GID 1000, matching the upstream chart's security context,
with read-only rootfs and writable `/data` and `/tmp`. Startup/liveness use the
real `/healthz` endpoint; readiness uses dependency-aware `/readyz`. Successful
pod startup alone is not evidence that a Secret was synced.
The sync worker's `LOGINLESS_MODE` skips its automatic token bootstrap; it does
not disable API authentication. The API has its own required token and rejects
an empty token at startup.

All three images use `:latest` with Keel polling every 24 hours. Upstream can
move `latest` on a prerelease tag, and the controller can decrypt the personal
vault. Check upstream changes and dashboard compatibility after updates.

## Bootstrap and Vault Scope

Active Kubernetes Login items live in the monitored `kubernetes-secrets`
folder and create their source Secrets in `shared-credentials`. The controller
needs the account's **user** API client ID/secret and master password;
organization API credentials are not supported. The existing
`utilities-priv/bitwarden-export-secret` contains credentials for that account;
they were copied to `utilities/vaultwarden-secrets-bootstrap` for the controller.
The controller can decrypt the **entire personal vault**, even though it filters
items by folder. Folder filtering is not an authorization boundary. A dedicated
account containing only Kubernetes items is preferable for long-term use.

Populate a local, gitignored `vaultwarden-secrets.env` using the companion
template; leave the committed template blank:

| Key | Value |
| --- | --- |
| `BW_CLIENTID` | `BW_CLIENTID` from the Bitwarden export credentials |
| `BW_CLIENTSECRET` | `BW_CLIENTSECRET` from the Bitwarden export credentials |
| `VAULTWARDEN__MASTERPASSWORD` | `BW_PASSWORD` from the Bitwarden export credentials |
| `VAULTWARDEN__FOLDERID` | ID of the `kubernetes-secrets` folder, not its name. Renaming the folder does not change its ID. |
| `VAULTWARDEN__DEVICEID` | Stable UUID for this controller. Preserve the existing device ID when migrating an installation. |
| `API_AUTH_TOKEN` | Independent dashboard API token. Preserve the existing token when consolidating a live installation. |

These values are already present in the live
`utilities/vaultwarden-secrets-bootstrap` Secret. Kustomize generates that
fixed-name Secret from the local file; it is not mounted directly. Before
applying to an existing installation, privately check that the local values
match the intended live values, since applying can overwrite them. An empty
folder ID disables the upstream filter and may cause other vault items to be
processed, so the init container rejects it. The device ID survives pod
replacement because it is explicitly configured outside the pod. The pilot
pins the existing upstream-derived ID (a GUID from the first 16 bytes of
SHA-256 over `ServerUrl:ClientId`, using .NET GUID byte order), rather than
introducing a new device. For a fresh installation, generate a UUID once with
`uuidgen` and keep it in the recovery copy. Vaultwarden can still notify on a
new ID or if the recognized device is removed. Unlocking the local MCP vault
does not provision or unlock the controller.

The bootstrap Secret cannot be fetched from the vault by the controller that
needs it to authenticate. Keep the local file and a protected offline recovery
copy independent of the controller. Never commit them or paste credentials
into chat.

If keeping archival Login items for bootstrap credentials, put them in the
separate, non-syncing `kubernetes-bootstrap` folder. This folder is not an
independent recovery source or an access boundary. After rotating bootstrap
credentials, update the local recovery files, offline backup, and any archival
items separately. Recover other application Secrets from Vaultwarden or its
backup.

After merging the reviewed manifests and filling all six values locally, apply
the Kustomization to create or update the bootstrap Secret and workloads:

```bash
kubectl apply -k kubernetes/utilities/bitwarden/vaultwarden-secrets/
```

The env file must exist on the machine running Kustomize, including when
building the parent `utilities/bitwarden` Kustomization. A clean GitHub Actions
checkout does not contain this gitignored file, so the deployment workflow
cannot build it without independently provisioning the file. Do not print or
save rendered Secret manifests in an unprotected location.

For a one-time upgrade, copy the old API Secret's `token` to `API_AUTH_TOKEN`
and add the stable device ID before deploying. Keep the old
`vaultwarden-secrets-api-auth` Secret for rollback to the old pod spec only.
Once that rollback is no longer needed, remove the old Secret so token rotation
has only one source. Since the generated name is fixed, restart the controller
after changing credentials in the env file and applying the Kustomization.

```bash
kubectl rollout restart deployment/vaultwarden-secrets -n utilities
kubectl rollout status deployment/vaultwarden-secrets -n utilities
```

## Dashboard and API

The dashboard is routed through Traefik at
`https://vaultwarden-secrets.kubernetes.timo.be` and
`https://vaultwarden-secrets.timo.be`, with the existing `traefik/auth` OIDC
middleware. The public hostname has a proxied Cloudflare DNS record and a
hostname on the Kubernetes tunnel pointing to Traefik; the IngressRoute alone
does not create them. Do not expose the API directly without authentication.

The API requires an **independent, strong random** token, not any of the
Bitwarden export credentials. The token now comes from the same bootstrap
Secret, but each container gets only its own keys via explicit `secretKeyRef`s.
Do not grant dashboard users or the dashboard container access to the
bootstrap Secret.

Keep the token private and enter it into the dashboard login after OIDC.
The API deliberately refuses to start if the token is empty: upstream would
otherwise disable its authentication. Rotate the local token, apply the
Kustomization, and restart the sync Deployment to reload it. The API and sync worker
share the database and temporary directory in one pod; no persistent history is
promised. Scaling the sync Deployment to zero also stops the API. Upstream's API
startup marks `InProgress` sync records as interrupted, so an API container
restart during an active sync can affect its displayed history. The dashboard's
published image currently uses same-origin `/api`; verify that remains true
after upstream updates.

## Login Mapping

Each **Login** item has a name matching its source Secret and maps to the
`shared-credentials` namespace. The password maps to the key named by
`secret-key-password`; other Secret keys use hidden custom fields with exact
key names. `namespaces` is `shared-credentials`, `context-name` is
`sectorfive`, and four `secret-annotation` fields set Reflector's allow and
automatic destination annotations. For example, the Sonarr item maps to:

| Field | Value |
| --- | --- |
| Name | `sonarr-api-key` |
| Password | Existing Sonarr API key |
| Custom text field: `secret-key-password` | `api-key` |
| Custom text field: `namespaces` | `shared-credentials` |
| Custom text field: `context-name` | `sectorfive` |
| Custom text field: `secret-annotation` | Reflector destinations `mediaplayback,utilities` |

The local MCP `create_item` and `edit_item` tools currently do not expose
custom fields. Use the official local Bitwarden CLI or the Vaultwarden UI to
create this complete mapping. Transfer values directly from the existing local
env file or live Secret without printing them. Check local and live values agree
before import; resolve differences rather than overwriting working credentials.

## Operations

The controller polls every five minutes. Updating a Login does not restart
consumers using environment variables. After verifying the source and reflected
Secrets, restart affected Deployments and check their rollouts:

```bash
kubectl rollout restart deployment/<name> -n <namespace>
kubectl rollout status deployment/<name> -n <namespace>
```

The original combined Recyclarr Login and its old Kubernetes Secret have been
retired. A controller restart preserves Kubernetes Secrets, although it discards
the controller's local history.

The checked-in and live RBAC permits Secret reads/writes only in
`shared-credentials`, plus read-only listing of namespace metadata required by
the upstream readiness check. Kubernetes cannot restrict `create` to a
particular resource name, so creation permission covers that namespace. Keep
only explicitly approved Kubernetes Secret Logins in the monitored folder.

## Rollback

For a source rollback, pause the controller before restoring its verified
recovery copy in `shared-credentials`. Recreate any missing Reflector mirrors,
privately compare their data, and restart affected environment-variable
consumers. Scaling the controller to zero pauses all synchronization and also
stops its API; resume it only after the Login and source Secret agree. Do not
reapply the bootstrap Kustomization after Vaultwarden takes ownership unless
recovering from a verified, current backup.
