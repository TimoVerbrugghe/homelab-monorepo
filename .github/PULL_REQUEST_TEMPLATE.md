## Summary

<!-- What does this PR change and why? -->

## Area(s) affected

<!-- Check all that apply -->
- [ ] Kubernetes manifests (`kubernetes/`)
- [ ] NixOS / Nix flake (`nixos/`)
- [ ] Ansible (`ansible/`)
- [ ] Docker Compose (`docker/`)
- [ ] GitHub Actions (`.github/workflows/`)
- [ ] Shell scripts
- [ ] Documentation / README
- [ ] Other: <!-- describe -->

## Changes

<!-- List the specific files changed and what was done -->
-
-

## How to test / apply

<!-- How should this be validated before merging? -->
```bash
# e.g.
kubectl apply --dry-run=server -k kubernetes/<service>/
```

## Checklist

- [ ] YAML passes `yamllint`
- [ ] Shell scripts pass `shellcheck`
- [ ] Kubernetes manifests include the full hardening baseline (`securityContext`, `resources`, probes)
- [ ] No `:latest` image tags introduced
- [ ] No secrets or credentials committed
- [ ] `.env.template` updated if new environment variables were added
- [ ] Maintenance matrix items reviewed (see `.github/copilot-instructions.md`)
