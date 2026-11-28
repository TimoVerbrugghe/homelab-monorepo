# Migrating Kubernetes Secrets to Vaultwarden

This runbook describes the centralized source-and-reflection design and how to
operate or recover it. The controller runs in `utilities`; Vaultwarden Logins
in the `kubernetes-secrets` folder create fixed-name source Secrets in
`shared-credentials`. Reflector distributes each whole Secret to explicitly
allowed consumer namespaces.

## Current design

- The controller defaults to `shared-credentials` and has Secret
  `create/get/list/patch/update` permission only in that namespace. Its
  cluster-scoped permission lists namespace metadata for readiness; it cannot
  read or write Secrets cluster-wide and has no Secret delete permission.
- Each active Login uses `namespaces=shared-credentials`,
  `context-name=sectorfive`, a `secret-key-password` field and explicit
  `secret-annotation` fields for Reflector's allow-list and automatic
  destinations.
- The source and destination inventory is in
  [`secret-bootstrap/README.md`](../../../secret-bootstrap/README.md). Its
  `.env.template` files document the bootstrap source keys; other keys are
  defined by the Vaultwarden Login items and consumer manifests. Do not infer
  extra destinations or copy a Secret into another namespace manually.
- `kubernetes/secret-bootstrap/` is a separate, manual bootstrap/recovery
  Kustomization for bootstrap-critical sources only. It is not included in
  service Kustomizations. Its populated `.env` files are gitignored local
  recovery material, not GitOps inputs. Recover other application Secrets from
  Vaultwarden or its backup.
- The former combined Recyclarr Login has been retired. Recyclarr, Swaparr and
  Homepage use separate reflected Sonarr/Radarr sources.
- `keel-qbittorrent-credential` supplies the same username and password to Keel
  and Homepage's qBittorrent widget. Rotate the qBittorrent Web UI credentials
  alongside this Login, then restart Keel and Homepage.

During migration validation, Homepage's pod could access the qBittorrent
transfer API without logging in. Review qBittorrent's authentication-bypass
settings if that network should require credentials.

Reflector copies the entire Secret. It does not merge selected keys into a
larger Secret, and it does not automatically adopt an existing same-name
destination. A conflicting destination must be removed during a controlled
handoff after the source is ready; otherwise it will not receive future
rotations. Deleting a source can delete automatic mirrors. Environment-variable
consumers require a restart after a value changes.

## Bootstrap and recovery

The controller cannot recover its own credentials from Vaultwarden. Keep
`vaultwarden-secrets.env`, the Vaultwarden server and export env files, and
other required bootstrap files outside Git with restrictive permissions and an
independent offline recovery copy. The controller's API token is separate from
the Bitwarden credentials. Keep controller bootstrap, Vaultwarden startup,
backup, and cluster-administration Secrets independently provisioned; generated
certificates, service-account tokens, and chart/operator credentials remain
with their owning controllers.

For a fresh cluster, install the cluster bootstrap components and Reflector,
create all destination namespaces, restore the ignored inputs described in
`kubernetes/secret-bootstrap/README.md`, and apply that Kustomization once.
Do not routinely reapply it: a stale local copy can overwrite rotated source
values. Before handing a bootstrap-created source to Vaultwarden, activate and
verify its Login, delete only that bootstrap-created source in
`shared-credentials`, and wait for the controller to recreate it with
Vaultwarden ownership metadata. Verify its reflected mirrors before moving to
the next source. Plan for a short mirror gap and perform this handoff in a
maintenance window.

## Security and prerequisites

- The controller uses a personal vault account. Its folder filter limits what
  it processes, **not what its credentials can decrypt**. Prefer a dedicated
  account containing only the intended Kubernetes items.
- Use the local Bitwarden CLI or Vaultwarden UI. The available Bitwarden MCP
  item tools do not expose all required custom fields.
- Never display values, session keys or credentials in terminal output, chat,
  logs, command arguments, shell history or Git. Base64 is not encryption.
- Keep local secret env files mode `0600` and retain a protected, verified
  recovery copy outside Git. Resolve any difference between a local source,
  Vaultwarden Login and live Secret before changing ownership.
- Readiness alone does not prove a successful sync. The controller polls
  every 300 seconds; check ownership metadata, exact key names, Reflector
  annotations and consumer readiness.

## Creating or updating a Login

Inventory the namespace, fixed Secret name, type, exact keys, source, every
consumer and any mounted Secret volumes. Do not import generated or
operator-owned Secrets. Use a protected local CLI session and build each Login
from an explicit allowlist; do not merge the Bitwarden item template because
it may contain sample values.

For each Login:

| Login field | Mapping |
| --- | --- |
| Name | Exact fixed Kubernetes source Secret name |
| Password | Value for the key named by `secret-key-password` |
| Hidden custom fields | Every other Secret key, using the exact key name |
| Text custom field `namespaces` | `shared-credentials` |
| Text custom field `context-name` | `sectorfive` |
| Text custom fields `secret-annotation` | `reflection-allowed=true`, `reflection-allowed-namespaces=<reviewed-list>`, `reflection-auto-enabled=true`, `reflection-auto-namespaces=<same-list>` |

Leave unused username, notes, URIs and TOTP empty. Verify the saved item's
folder, fields, sync metadata and private value equality before relying on it.
Do not place archival items in the monitored `kubernetes-secrets` folder.

## Cutover and verification

1. Confirm the shared source namespace, scoped Role/RoleBinding, controller,
   Reflector and destination namespaces are ready.
2. Verify the Login has the intended name, exact keys, values, controller
   context and Reflector destinations without printing secret contents.
3. Wait for the source Secret in `shared-credentials`. Confirm the
   `vaultwarden-kubernetes-secrets` managed-by label and `managed-keys`
   metadata.
4. If an existing same-name destination prevents reflection, verify its
   recovery copy and consumers, then delete that destination during the
   cutover. Wait for Reflector to create the mirror and compare the payload
   privately. If the destination remains absent, trigger reconciliation by
   adding a temporary metadata annotation to the central source, wait for the
   expected mirror, then remove the temporary annotation:

    ```bash
    kubectl annotate secret <name> -n shared-credentials \
      migration.refresh="$(date +%s)" --overwrite
    # Verify the mirror's `reflects` annotation and keys before continuing.
    kubectl annotate secret <name> -n shared-credentials migration.refresh-
    ```

    The temporary annotation contains no secret data and is copied to mirrors
    until removed. Do not leave a destination absent or proceed to the next
    Secret before verifying it.
5. Restart consumers that read Secret values through environment variables;
   verify their rollouts and application authentication. Secret volume
   projections may update eventually, but applications may need a restart.

For metadata-only inspection:

```bash
kubectl -n shared-credentials get secret <name> -o json \
  | jq '{name: .metadata.name, type: .type,
         managedBy: .metadata.labels["app.kubernetes.io/managed-by"],
         keys: (.data | keys),
         annotations: (.metadata.annotations | with_entries(select(.key | startswith("reflector.v1.k8s.emberstack.com/"))))}'
```

Never paste rendered Secret manifests, raw controller logs or secret values
into an issue, pull request or chat.

## Rotation and rollback

For rotation, prepare and verify a recovery copy, update the existing Login,
wait for the source and mirrors to converge, privately verify the new values,
and restart environment-variable consumers. If the change is not expected,
pause reconciliation before restoring the previous Secret. Scaling the
controller to zero pauses synchronization for every destination and stops the
API; resume only after correcting the Login or deciding to roll back.

Older Keel and Homepage Deployment revisions reference the retired
`keel-credentials` and `qbittorrent-credential` Secrets. Before rolling back
to those revisions, restore the old Secrets from protected rollback data or
deploy a compatible Pod template that uses `keel-qbittorrent-credential`.

The controller has orphan deletion disabled and no Secret delete permission.
Do not assume removing a Login cleans up its Secret or mirrors. Remove an
obsolete item from the monitored folder, verify that it cannot recreate the
source, then retire its source and mirrors explicitly after checking all
consumers. Retain the Vaultwarden item and recovery copy until rollback is no
longer needed.
