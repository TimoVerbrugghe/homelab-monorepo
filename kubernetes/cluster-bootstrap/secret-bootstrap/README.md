# Bootstrap Secrets

`cluster-bootstrap` includes these generators for initial setup and recovery.
Restore the gitignored `.env` files from a protected backup, using the
templates as a key reference. Never commit or print the populated files.

The generators write fixed-name Secrets to `shared-credentials`. Reflector
copies them when the destination namespaces exist. Once Vaultwarden takes
ownership, apply individual components for routine changes: reapplying the
parent can overwrite newer credentials.

For handoff, verify the matching Vaultwarden Login and recovery copy. Replace
one bootstrap source at a time during a maintenance window, verifying the
controller-created source and its mirrors before continuing. Existing
same-name destination Secrets are not automatically adopted.
