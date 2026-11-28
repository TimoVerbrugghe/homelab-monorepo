---
name: vaultwarden-kubernetes-secrets
description: 'Manage Kubernetes secrets with Vaultwarden and Reflector. Use when deploying workloads that need secrets, migrating existing Secrets, or rotating shared credentials.'
license: Complete terms in LICENSE.txt
---

# Vaultwarden Kubernetes Secrets

For workloads that need sensitive values, prefer the existing Vaultwarden
controller and Login item mapping. Do not create a Secret when none is needed.
Read the [migration guide](../../../kubernetes/utilities/bitwarden/vaultwarden-secrets/migration.md)
before creating, migrating, or rotating a Secret.

## Workflow

- Identify the Secret name, keys, consumers, destination namespaces, and source
  of values without displaying them. Reuse an existing shared credential when
  appropriate; do not create duplicate Logins or import unrelated items.
- Store each active source in a Vaultwarden Login in `kubernetes-secrets`.
  Set `namespaces=shared-credentials`, `context-name=sectorfive`, and
  `secret-key-password` for the Login password key; use hidden custom fields
  for remaining keys. Preserve consumer-facing names or update the consumers.
- Configure the Login's Reflector annotations with explicit allowed and
  automatic destination namespaces. The controller creates the source in
  `shared-credentials`; Reflector copies the whole Secret to those namespaces.
  Keep the controller's Secret permissions scoped to `shared-credentials`:
  adding a consumer namespace does not require extending its Secret RBAC.
- Keep a protected rollback source. The controller's vault folder filter is
  not an authorization boundary, and Reflector retains cluster-wide access.
- Avoid competing ownership: retire application Secret generators after
  migration, but retain required ConfigMap generators. Keep bootstrap
  generators for recovery only, independently of Vaultwarden sync.
- Create or change live vault items, Kubernetes resources, or consumers only
  when the user has authorized the relevant operational work. For a code-only
  request, describe the required vault setup without performing it.
- Verify sync and values privately, then restart affected consumers when
  necessary. Report only metadata and verification results, never secret values.

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
  mirrors. A reflected Secret includes all of its keys.
