# AGENTS.md — Homelab Monorepo

This file helps AI coding agents understand how the repository is structured, how to make changes, and what conventions to follow.

## Project Overview

A personal homelab configuration repository covering infrastructure-as-code for
a multi-node Proxmox cluster, Talos Linux Kubernetes cluster, NixOS machines,
TrueNAS Scale Docker workloads, and supporting automation.

The repo is **configuration-as-code** — there is no compiled application, no
package.json, no build artifact. The "output" of changes is updated manifests,
configs, and playbooks that are applied to live infrastructure.

## Repository Structure

```text
ansible/           Ansible playbooks and roles for host provisioning
diagrams/          draw.io architecture diagrams (auto-exported to PNG via CI)
docker/            Docker Compose stacks
  truenas/         Services running on TrueNAS Scale via Docker
  david/           Services running on a dedicated media/utility host
homeassistant/     Home Assistant scripts and automation helpers
kubernetes/        Kubernetes manifests, all Kustomize-based
  <service>/       One directory per service; each has kustomization.yaml
  cluster-bootstrap/   Talos bootstrap and cluster-level configs
  talos/           Talos machine configs
nixos/             NixOS flake — all machines and shared modules
  flake.nix        Top-level flake, defines all machines
  machines/        Per-machine NixOS configuration
  modules/         Shared reusable NixOS modules
  isos/            Definitions for bootable NixOS ISOs
tailscale/         Tailscale serve/funnel JSON configs
truenas/           TrueNAS helper scripts (cron jobs, rclone, backups)
windows/           WinPE and unattend XML for Windows installs
steamdeck/         Steam Deck app lists and custom grids
.github/
  workflows/       GitHub Actions workflows
  instructions/    Copilot instruction files (applyTo patterns)
  agents/          Custom Copilot agent definitions
```

## Tech Stack

| Area | Technology |
| ------ | ----------- |
| Kubernetes | Talos Linux, Kustomize (service directories use plain manifests; do not use `helmCharts:` in this repository) |
| Container runtime | containerd (via Talos) |
| NixOS | Nix flakes, nixpkgs stable + unstable channels |
| Docker Compose | Compose v2 on TrueNAS Scale and David host |
| Provisioning | Ansible (collections in `ansible/collections/requirements.yaml`) |
| DNS / ad-blocking | AdGuard Home (Kubernetes + NixOS) |
| Ingress | Traefik (Kubernetes), Cloudflare Tunnel (NixOS) |
| VPN mesh | Tailscale |
| Secrets (runtime) | Kubernetes Secrets, Talos secrets, env files (`.env.template` patterns) |
| CI | GitHub Actions |
| Linting | yamllint, jsonlint, shellcheck, markdownlint |

## Key Machines

| Name | Role | Config location |
| ------ | ------ | ---------------- |
| TheFactory | TrueNAS Scale NAS | `docker/truenas/` |
| Yumi | K8s node (HA, local storage) | `kubernetes/`, `ansible/` |
| William, Manta, Skidbladnir | K8s worker nodes | `kubernetes/`, `ansible/` |
| Odd, Ulrich | AdGuard Home on NixOS | `nixos/machines/odd/`, `nixos/machines/ulrich/` |
| Hass | Home Assistant OS VM | managed outside this repo |
| David | Dedicated media/utility host | `docker/david/`, `nixos/machines/david/` |
| MacBook Air | Personal laptop (nix-darwin) | `nixos/machines/macbookair/` (entry in `darwinConfigurations`) |

## Running / Applying Changes

All code changes must go through a feature branch and a PR against `main`. The commands below are reference commands for applying already-merged manifests or for manual operations on the cluster — they are not a substitute for the PR workflow.

## Git Workflow

Always create a feature branch and open a PR against `main`.
Do not commit directly to `main`.

### Kubernetes (Kustomize)

```bash
# Dry-run a service change
kubectl apply --dry-run=client -k kubernetes/<service>/

# Apply a service
kubectl apply -k kubernetes/<service>/

# Deploy via GitHub Actions (workflow_dispatch)
# .github/workflows/deploy-k8s-resource.yaml → input: resource name, action: apply/delete
```

### NixOS

```bash
# Rebuild local machine
sudo nixos-rebuild switch --flake nixos/#<machine-name>

# Build an ISO
nix build nixos/#<iso-name>

# Check flake inputs
nix flake show nixos/
```

### Ansible

```bash
# Install collections first
ansible-galaxy collection install -r ansible/collections/requirements.yaml

# Run a playbook
ansible-playbook ansible/playbooks/<playbook>.yaml -i ansible/inventory/hosts.yaml
```

### Docker Compose (TrueNAS / David)

```bash
docker compose -f docker/truenas/<stack>.yaml up -d
docker compose -f docker/david/<stack>.yaml up -d
```

### Linting (matches CI)

```bash
yamllint .
find . -name "*.sh" -exec shellcheck {} \;
find . -name "*.json" -exec jsonlint -q {} \;
```

## Adding a New Kubernetes Service

1. Create `kubernetes/<service-name>/` directory.
2. Add a `namespace.yaml` if the service gets its own namespace.
3. Add Kubernetes manifest files (Deployment, Service, Ingress, etc.).
4. Add `kustomization.yaml` referencing all resources:

   ```yaml
   apiVersion: kustomize.config.k8s.io/v1beta1
   kind: Kustomization
   resources:
     - namespace.yaml
     - deployment.yaml
     - service.yaml
   ```

   If the service needs secrets, add a committed `<service>-secrets.env.template`
   file with placeholder values, keep the real `<service>-secrets.env` local and
   uncommitted, and generate the Kubernetes Secret via `secretGenerator` in
   `kustomization.yaml`.

5. Apply with `kubectl apply -k kubernetes/<service-name>/`.
6. The `deploy-k8s-resource.yaml` workflow can deploy it via `workflow_dispatch`.

All manifests must follow the hardening baseline in
`.github/instructions/kubernetes-deployment-best-practices.instructions.md`.
Read that file before generating new workload manifests, and use it as the
single source of truth. If you cannot access that file, ask the user to
provide it before generating any manifests.

## Adding a New NixOS or nix-darwin Machine

1. Create `nixos/machines/<machine-name>/default.nix` (or a directory with
  `default.nix`). This path is used for both NixOS and nix-darwin machine
  configs in this repo.
2. Add the machine to `nixos/flake.nix` under `nixosConfigurations` (NixOS)
  or `darwinConfigurations` (macOS).
3. Import shared modules from `nixos/modules/` as needed.
4. For ISOs, add the definition to `nixos/isos/` and add it to the build matrix in `.github/workflows/build-nixos-isos.yaml`.

## Adding an Ansible Playbook

1. Create `ansible/playbooks/<name>.yaml`.
2. Reference hosts from `ansible/inventory/hosts.yaml`.
3. Place reusable tasks in `ansible/roles/`.
4. Add a corresponding wrapper script in `ansible/scripts/` if needed.

## Adding a Docker Compose Service

1. Add a YAML file to `docker/truenas/` or `docker/david/` depending on the host.
2. For services with secrets, create a `<name>.env.template` alongside the compose file and document required variables.
3. Never commit actual `.env` files — only `.env.template` files with placeholder values.

## Secrets and Sensitive Data

- **Never commit secrets, tokens, passwords, or API keys.**
- Use `.env.template` files with placeholder values for Docker Compose secrets.
- For Kubernetes workloads, commit a `<service>-secrets.env.template` file,
  create the real `<service>-secrets.env` locally, and load it through
  `secretGenerator` in `kustomization.yaml`. Do not commit the real `.env`
  file or raw Secret manifests. Always document the required secret file name
  and expected keys in a `README.md` within the service directory.
- The `.vscode/mcp.json` uses `${input:...}` syntax so secrets are prompted at runtime, never stored.
- `recyclarr/secrets.yaml.template` is the template pattern — the real `secrets.yaml` is gitignored.

## Common Pitfalls

- **Git workflow**: always create a feature branch and open a PR against
  `main`; do not commit directly to `main`.
- **Branch name**: default branch is `main`. Several older workflow files
  reference `master` — this is a known inconsistency; new workflows should use
  `main`.
- **yamllint**: the `.yamllint` or inline yamllint config is strict; check that your YAML passes before pushing. Multi-line strings often need `|` or `>` blocks.
- **Kubernetes hardening**: use
  `.github/instructions/kubernetes-deployment-best-practices.instructions.md`
  as the single source of truth.
- **Kustomize, not Helm**: the cluster uses plain Kustomize. Prefer rendered
  manifests for service directories. Do not use `helmCharts:`.
- **NixOS flake inputs**: always run `nix flake update` in `nixos/` after changing inputs; keep the lock file committed.
- **Docker Compose env files**: `*.env` files are gitignored — only commit `*.env.template` files with `VARIABLE_NAME=` placeholders.
- **Kubernetes secret files**: follow the existing repo pattern of
  `<service>-secrets.env.template` plus a local uncommitted
  `<service>-secrets.env`, referenced from `secretGenerator` in
  `kustomization.yaml`.
- **iSCSI storage**: Plex and Jellyfin use iSCSI-backed PersistentVolumes. Do not change their storage class to NFS-backed — there are known sqlite corruption issues.
- **Host networking**: the `pxeboot` and discovery-relay workloads use `hostNetwork: true` for L2/multicast access. This is intentional and documented.

## CI Workflows Summary

| Workflow file | Trigger | Purpose |
| -------------- | --------- | --------- |
| `build-nixos-isos.yaml` | tag push `v*`, release | Build NixOS ISOs and attach to release |
| `check-broken-links.yaml` | push/PR on `*.md` | Check markdown links |
| `deploy-k8s-resource.yaml` | `workflow_dispatch` | Apply/delete a Kubernetes service |
| `drawio-export.yaml` | push on `*.drawio` | Export draw.io diagrams to PNG |
| `iscsi-kubernetes.yaml` | `workflow_dispatch` | iSCSI volume management |
| `lint-markdown.yaml` | push/PR on `*.md` | markdownlint |
| `lint-yaml-json.yaml` | push/PR on `*.yaml`, `*.json` | yamllint + jsonlint |
| `sync-external-skills.yaml` | weekly schedule + `workflow_dispatch` | Sync vendored external Copilot skills and push updates to `main` |
| `rotate-cluster-credentials.yaml` | `workflow_dispatch` | Rotate Talos/kubeconfig credentials |
| `update-badges.yaml` | push on `main` | Regenerate README count badges |
| `update-talos-machines.yaml` | `workflow_dispatch` | Update Talos machine configs |
| `validate-shell-scripts.yaml` | push/PR on `*.sh` | shellcheck + bash syntax |
| `build-winpe-image.yaml` | weekly schedule + `workflow_dispatch` | Build WinPE ISO with virtio-win drivers, upload to TheFactory via Tailscale, send Pushover notification |

## Documentation

- Architecture diagram: `diagrams/homelab.drawio` (auto-exported to PNG)
- Internal IPs reference: `internal_ips.md`
- Per-service notes: `kubernetes/README.md`
- Steam Deck setup: `steamdeck/`
- Home Assistant scripts: `homeassistant/scripts/README.md`
