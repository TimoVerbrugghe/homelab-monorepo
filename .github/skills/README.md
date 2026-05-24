# External Skills

This folder vendors external skills that are synced automatically.

## Managed skills

- `portainer-mcp-hygiene` from `https://raw.githubusercontent.com/portainer/portainer-mcp/main/skills/portainer-mcp-hygiene/SKILL.md`
- `siderolabs` from `https://docs.siderolabs.com/skill.md`

## Update process

- Automated sync: `.github/workflows/sync-external-skills.yaml` (weekly + manual trigger)
- When changes are detected, the workflow commits and pushes directly to `main`.
