# External Skills

This folder contains project skills and vendored external skills.

## Project skills

- `vaultwarden-kubernetes-secrets` for Kubernetes Secret migrations and deployments.

## Managed external skills

- `portainer-mcp-hygiene` from `https://raw.githubusercontent.com/portainer/portainer-mcp/main/skills/portainer-mcp-hygiene/SKILL.md`
- `siderolabs` from `https://docs.siderolabs.com/skill.md`

## Update process

- Automated sync: `.github/workflows/sync-external-skills.yaml` (weekly + manual trigger)
- When changes are detected, the workflow commits and pushes directly to `main`.
