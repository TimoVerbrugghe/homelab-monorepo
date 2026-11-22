# Vaultwarden Secrets: Recyclarr Pilot

## Status

The `recyclarr-secrets` Login in the personal Vaultwarden account's
`kubernetes-sectorfive-recyclarr` folder is the source of
`mediaplayback/recyclarr-secrets`. The sync Deployment runs in `utilities`.
Recyclarr no longer generates this Secret from the local env file.

This is a plain Kustomize deployment of the
[upstream controller](https://github.com/antoniolago/vaultwarden-kubernetes-secrets/tree/v2.2.0).
Helm, CRDs, API/dashboard components, and PVCs are not required. The controller
still needs writable SQLite/cache storage: memory-backed `emptyDir` provides it.
Restarting loses sync history/cache, not the vault items or Kubernetes Secrets.
Automatic orphan deletion is disabled and RBAC grants no delete permission.
Use one replica with `Recreate` to avoid concurrent reconcilers.

The container uses UID/GID 1000, matching the upstream chart's security context,
with read-only rootfs and writable `/data` and `/tmp`. Startup/liveness use the
real `/healthz` endpoint; readiness uses dependency-aware `/readyz`. Successful
pod startup alone is not evidence that a Secret was synced.
`LOGINLESS_MODE` skips the unused API token bootstrap in this sync-only
deployment. Do not deploy the optional API or dashboard in loginless mode.

## Bootstrap and Vault Scope

The pilot Login currently lives in the personal Vaultwarden account. The
controller needs its **user** API client ID/secret and master password;
organization API credentials are not supported. The existing
`utilities-priv/bitwarden-export-secret` contains credentials for that account;
they were copied to `utilities/vaultwarden-secrets-bootstrap` for the controller.
The controller can decrypt the **entire personal vault**, even though it filters
items by folder. Folder filtering is not an authorization boundary. A dedicated
account containing only pilot items is preferable for long-term use.

Populate a local, gitignored `vaultwarden-secrets.env` using the companion
template. `VAULTWARDEN__FOLDERID` must be the nonempty ID of the pilot folder,
not its name. An empty folder ID disables the upstream filter and may cause
other vault items to be processed, so the init container rejects it. Unlocking
the local MCP vault does not provision those credentials or unlock the cluster
controller.

The bootstrap Secret cannot be fetched from the vault by the controller that
needs it to authenticate. Provision it independently and keep a protected
offline recovery copy. Never commit it or paste credentials into chat.

After merging the reviewed manifests and filling all four values locally:

```bash
kubectl create secret generic vaultwarden-secrets-bootstrap \
  -n utilities \
  --from-env-file=kubernetes/utilities/bitwarden/vaultwarden-secrets/vaultwarden-secrets.env
kubectl apply -k kubernetes/utilities/bitwarden/vaultwarden-secrets/
```

If the bootstrap Secret already exists, update it through a protected pipeline,
not by deleting it. Restart the controller after credential changes.

## Login Mapping

The **Login** item has no username, notes, or URIs. It maps to one
`mediaplayback/recyclarr-secrets` Secret:

| Field | Value |
| --- | --- |
| Name | `recyclarr-secrets` |
| Password | Existing `RADARR_API_KEY` |
| Custom hidden field: `SONARR_API_KEY` | Existing `SONARR_API_KEY` |
| Custom text field: `namespaces` | `mediaplayback` |
| Custom text field: `secret-key-password` | `RADARR_API_KEY` |
| Custom text field: `context-name` | `sectorfive` |

The local MCP `create_item` and `edit_item` tools currently do not expose
custom fields. Use the official local Bitwarden CLI or the Vaultwarden UI to
create this complete mapping. Transfer values directly from the existing local
env file or live Secret without printing them. Check local and live values agree
before import; resolve differences rather than overwriting working credentials.

## Operations

The controller polls every five minutes. Updating a Login does not restart
consumers using environment variables. After verifying that the Secret has
synced, restart Recyclarr and check its rollout:

```bash
kubectl rollout restart deployment/recyclarr -n mediaplayback
kubectl rollout status deployment/recyclarr -n mediaplayback
```

The manual Secret was deleted and recreated by the controller during the
pilot, and both keys matched the protected pre-cutover copy. Recyclarr's Sonarr
and Radarr preview syncs succeeded. A controller restart preserves the Secret,
although it discards the controller's local history.

RBAC permits Secret reads/writes only in `mediaplayback`, plus read-only
listing of namespace metadata required by the upstream readiness check.
Kubernetes cannot restrict `create` to a particular resource name, so creation
permission covers that namespace. Do not add unrelated vault items to the
pilot folder.

## Rollback

Scale the controller to zero first. Restore a protected Secret backup or
recreate it from the local gitignored Recyclarr env file, then restart Recyclarr.
Verify rollout and authentication. If permanently reverting, restore
Recyclarr's original `secretGenerator` in Git as well. Do not delete the vault
item or bootstrap credentials until recovery is confirmed.
