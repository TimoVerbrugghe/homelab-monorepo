---
name: vaultwarden-kubernetes-secrets
description: 'Manage Kubernetes secrets with Vaultwarden and Reflector. Use when deploying workloads that need secrets, migrating existing Secrets, or rotating shared credentials.'
---

# Vaultwarden Kubernetes Secrets

For workloads that need sensitive values, prefer the existing Vaultwarden
controller and Login item mapping. Do not create a Secret when none is needed.
See the [Login mapping](../../../kubernetes/utilities/bitwarden/vaultwarden-secrets/README.md)
for exact field and annotation syntax.

## Workflow

- Identify the Secret name, keys, consumers, destination namespaces, and source
  of values without displaying them. Reuse an existing shared credential when
  appropriate; do not create duplicate Logins or import unrelated items. Keep
  shared keys separate from app-only keys: workloads can reference multiple
  Secrets, but Reflector cannot copy just one key from a Secret.
- Store each active source in a Vaultwarden Login in `kubernetes-secrets`.
  Set `namespaces=shared-credentials`, `context-name=sectorfive`, and
  `secret-key-password` for the Login password key; use hidden custom fields
  for remaining keys. Name keys for what consumers receive (`password` for
  passwords, `token` for tokens). Keep old names or keys available until the
  replacements have synced and consumers have rolled out.
- Configure the Login's Reflector annotations with explicit allowed and
  automatic destination namespaces. The controller creates the source in
  `shared-credentials`; Reflector copies the whole Secret to those namespaces.
  Keep the controller's Secret permissions scoped to `shared-credentials`:
  adding a consumer namespace does not require extending its Secret RBAC.
  The only cluster-scoped controller permission lists namespace metadata.
- Keep a protected rollback source. The controller's vault folder filter is
  not an authorization boundary: it can decrypt the personal vault. Prefer a
  dedicated account. Reflector retains cluster-wide access.
- Avoid competing ownership: retire application Secret generators after
  migration, but retain required ConfigMap generators. Keep bootstrap
  generators for bootstrap and recovery only. Keep the controller's own
  credentials and independent, nonempty API token outside the sync folder.
  Keep protected offline recovery inputs; any archival Logins belong in
  `kubernetes-bootstrap`, not the monitored folder. Do not import generated
  or operator-owned credentials.
- Create or change live vault items, Kubernetes resources, or consumers only
  when the user has authorized the relevant operational work. For a code-only
  request, describe the required vault setup without performing it.
- Sync runs every five minutes. Verify source ownership and managed keys,
  the mirrors' `reflects` annotations, and private equality of decoded values
  before rolling out consumers. Pod readiness alone does not prove a sync.

## Gotchas

- **A matching Login can change an existing Secret on the next sync.** Stage
  the cutover with reconciliation paused and a verified recovery copy. A
  matching unmanaged Secret may also be skipped without acquiring ownership.
- **Do not put secrets in Git, chat, shell history, command arguments, logs, or
  tool output.** The current Bitwarden MCP item tools may not support custom
  fields; use a protected local CLI session or the Vaultwarden UI instead.
- **Bitwarden Login templates contain sample values, including a TOTP seed.**
  Build the `login` object from an allowlist instead of merging the Login
  template. Explicitly leave TOTP empty unless requested. Read back the saved
  item privately and confirm unused fields are blank.
- **Never remove a manual Secret without a verified recovery source and an
  authorized cutover.** Deletion can cause disruption until reconciliation.
- **Environment variables do not update in running containers.** Restart each
  affected workload after confirming the Secret has changed.
- **Reflector skips existing automatic-mirror conflicts.** Perform a controlled
  replacement after verifying recovery; deleting a source can delete automatic
  mirrors. If a replacement mirror does not appear, trigger reconciliation
  with a temporary metadata annotation on the source, then remove it.
- **Removing a Login does not remove its Kubernetes Secret.** Orphan deletion
  is disabled. Retire the unused source and mirrors explicitly after checking
  consumers and rollback revisions.
- **Rollback affects Vaultwarden and Kubernetes.** Pause sync before restoring
  prior values, and resume once the Login and source agree. Scaling down the
  sync Deployment also stops its API. Restore retired Secrets before rolling
  back workloads to revisions that reference them.
