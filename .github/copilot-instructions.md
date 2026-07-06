# Copilot Instructions — Homelab Monorepo

This repository is a personal homelab configuration monorepo. It contains **no compiled application code** — everything is infrastructure-as-code:
Kubernetes manifests (Kustomize), NixOS flake configs, Ansible playbooks, Docker Compose stacks, and shell scripts.

---

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
# .github/workflows/deploy-k8s-resource.yaml -> input: resource name, action: apply/delete
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

## Common Change Tasks

### Adding a New Kubernetes Service

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

### Adding a New NixOS or nix-darwin Machine

1. Create `nixos/machines/<machine-name>/default.nix` (or a directory with
   `default.nix`). This path is used for both NixOS and nix-darwin machine
   configs in this repo.
2. Add the machine to `nixos/flake.nix` under `nixosConfigurations` (NixOS)
   or `darwinConfigurations` (macOS).
3. Import shared modules from `nixos/modules/` as needed.
4. For ISOs, add the definition to `nixos/isos/` and add it to the build matrix in `.github/workflows/build-nixos-isos.yaml`.

### Adding an Ansible Playbook

1. Create `ansible/playbooks/<name>.yaml`.
2. Reference hosts from `ansible/inventory/hosts.yaml`.
3. Place reusable tasks in `ansible/roles/`.
4. Add a corresponding wrapper script in `ansible/scripts/` if needed.

### Adding a Docker Compose Service

1. Add a YAML file to `docker/truenas/` or `docker/david/` depending on the host.
2. For services with secrets, create a `<name>.env.template` alongside the compose file and document required variables.
3. Never commit actual `.env` files — only `.env.template` files with placeholder values.

## YAML Conventions

- Always use the `.yaml` extension — never `.yml`.
- Indent with **2 spaces** — never tabs.
- Multi-line strings use `|` (literal block) or `>` (folded block) — never inline newlines.
- All YAML files must pass `yamllint` as configured in `.github/workflows/lint-yaml-json.yaml`.
- Keys in alphabetical order within a mapping when there is no semantic reason to order otherwise.
- Avoid trailing whitespace.

## Kubernetes Conventions

The cluster uses **Kustomize** — plain manifests with `kustomization.yaml` files. No Helm at the service level (Helm charts may be rendered to plain manifests).

### Manifest structure

- Every service lives in `kubernetes/<service-name>/`.
- Every service directory **must** contain a `kustomization.yaml`.
- Namespace-scoped services include a `namespace.yaml` in the same directory.
- Ordering in `kustomization.yaml` resources: `namespace.yaml` first, then other manifests.

### Hardening baseline (required on all workloads)

Every Deployment, StatefulSet, DaemonSet, Job, and CronJob must include:

**Pod securityContext:**

```yaml
securityContext:
  seccompProfile:
    type: RuntimeDefault
  runAsNonRoot: true
  runAsUser: <uid>    # set to image's actual UID
  fsGroup: <gid>      # set when volume ownership matters
```

**Container securityContext:**

```yaml
securityContext:
  allowPrivilegeEscalation: false
  readOnlyRootFilesystem: true
  capabilities:
    drop:
      - ALL
stdin: false
tty: false
```

**Resources (required on every container):**

```yaml
resources:
  requests:
    cpu: "50m"
    memory: "64Mi"
  limits:
    cpu: "500m"
    memory: "256Mi"
```

**Probes (required on Deployments):**

```yaml
livenessProbe:
  httpGet:
    path: /healthz
    port: <port>
  initialDelaySeconds: 15
  periodSeconds: 20
readinessProbe:
  httpGet:
    path: /readyz
    port: <port>
  initialDelaySeconds: 5
  periodSeconds: 10
```

When `readOnlyRootFilesystem: true` is set, add emptyDir mounts for any paths the container writes to:

```yaml
volumeMounts:
  - name: tmp
    mountPath: /tmp
volumes:
  - name: tmp
    emptyDir:
      medium: Memory
```

**Exception policy:** If an image cannot satisfy the full baseline, explicitly override only the failing fields and add an inline comment
explaining why (e.g. `# image runs as root, no non-root user available`). Keep exceptions as narrow as possible.

### Labels

All resources must have consistent labels:

```yaml
labels:
  app.kubernetes.io/name: <service-name>
  app.kubernetes.io/instance: <service-name>
  app.kubernetes.io/part-of: homelab
```

### Image tags

- Never use `:latest` — always pin to a specific version tag.
- Image digests (`@sha256:...`) are preferred for critical workloads.

### Storage

- iSCSI-backed PVs are used for Plex and Jellyfin — **do not change to NFS**.
- Local-path PVs are used for stateful workloads on the Yumi node.
- Services that don't need persistent state should use emptyDir or no volumes at all.

## Docker Compose Conventions

- One logical stack per file (e.g. `media.yaml`, `downloaders.yaml`).
- Services that require secrets use a companion `<stack>.env.template` — **never commit actual `.env` files**.
- The `.env.template` file lists all required variables with empty values or example values:

  ```env
  VARIABLE_NAME=
  OTHER_VAR=example_value_here
  ```

- Always specify `restart: unless-stopped` (or `restart: always` for critical services).
- Pin image versions — no `:latest` tags.
- Networks: use named networks with `driver: bridge`; avoid `network_mode: host` unless required (e.g. multicast relay).

## NixOS / Nix Flake Conventions

- The flake entry point is `nixos/flake.nix`.
- Machine configs live in `nixos/machines/<name>/` (directory with `default.nix`).
- Shared modules live in `nixos/modules/` and are imported by machines that need them.
- Use the stable channel (`nixpkgs` → `nixos-25.11`) by default; unstable is available for packages not yet in stable.
- Keep `nixos/flake.lock` committed — it is the source of truth for package versions.
- Run `nix flake check nixos/` before committing flake changes.

## Ansible Conventions

- Inventory: `ansible/inventory/hosts.yaml` (static inventory).
- Group vars: `ansible/inventory/group_vars/`.
- Roles in `ansible/roles/<role-name>/` follow the standard Ansible role directory layout.
- Collections required: listed in `ansible/collections/requirements.yaml` — run `ansible-galaxy collection install -r ansible/collections/requirements.yaml` before running playbooks.
- Playbooks should be idempotent.
- Use `ansible-lint` to validate playbooks before committing.

## Shell Script Conventions

- All scripts are written in `bash` with `#!/usr/bin/env bash` shebang.
- Every script must pass `shellcheck` with severity `warning` and options `-x -e SC1091`.
- Use `set -euo pipefail` at the top of scripts.
- Quote all variable expansions: `"$var"` not `$var`.
- Scripts in `ansible/scripts/` are thin wrappers around `ansible-playbook` commands.

## GitHub Actions Conventions

- Pin third-party actions to a specific SHA or version tag — not `@main`.
- Use `actions/checkout@v4` (or the pinned version used in existing workflows) consistently.
- Set `permissions: read-all` (or the minimum required) on jobs.
- Use `workflow_dispatch` for operational workflows (deploy, rotate, iSCSI).
- Use `pull_request` + `push` on `main` triggers for linting and validation workflows.
- Add `paths:` filters so workflows only run when relevant files change.
- See `.github/instructions/github-actions-ci-cd-best-practices.instructions.md` for the full guide.

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
| `dependabot-auto-merge.yaml` | `pull_request` from dependabot | Auto-approve and squash-merge Dependabot PRs |
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
| `build-winpe-image.yaml` | `workflow_dispatch` + push on `windows/**` | Build WinPE ISO with virtio-win drivers, upload to TheFactory via Tailscale, send Pushover notification. On push: full build if `startnet.cmd` changes; XML-only upload if only unattend XMLs change |

## Documentation

- Architecture diagram: `diagrams/homelab.drawio` (auto-exported to PNG)
- Internal IPs reference: `internal_ips.md`
- Per-service notes: `kubernetes/README.md`
- Steam Deck setup: `steamdeck/`
- Home Assistant scripts: `homeassistant/scripts/README.md`

---

## Maintenance Matrix

When you change a file in column A, you must also review/update the files in column B.

| Changed file / area | Also check / update |
| -------------------- | --------------------- |
| `kubernetes/<service>/` manifests | `kubernetes/<service>/kustomization.yaml` (resource list); the `CI Workflows Summary` section in this file if a new workflow is added |
| Add a new Kubernetes service directory | `kubernetes/README.md`; the `CI Workflows Summary` section in this file if applicable |
| `nixos/flake.nix` inputs | `nixos/flake.lock` (run `nix flake update`); per-machine configs if module API changed |
| `nixos/modules/<module>.nix` | All `nixos/machines/*/default.nix` files that import that module |
| Add a new NixOS machine | `nixos/flake.nix` (add to `nixosConfigurations`); `ansible/inventory/hosts.yaml` if it needs Ansible |
| `ansible/collections/requirements.yaml` | the `Running / Applying Changes` -> `Ansible` section in this file; any CI that installs collections |
| `ansible/inventory/hosts.yaml` | Any playbook targeting changed hosts; the `Key Machines` section in this file |
| Add a new Ansible role | `ansible/collections/requirements.yaml` if it needs a new collection; playbook that uses the role |
| `docker/<host>/<stack>.yaml` | Companion `<stack>.env.template` if new env vars are added; `README.md` service list if applicable |
| Add a new Docker Compose stack | Companion `.env.template`; the `Common Change Tasks` -> `Adding a Docker Compose Service` section in this file |
| `.github/workflows/*.yaml` (new workflow) | `README.md` GitHub Workflows Status badge section; the `CI Workflows Summary` section in this file; `update-badges.yaml` if badge count changes |
| `.github/workflows/update-badges.yaml` | `README.md` badge section (auto-generated, but verify count patterns still match) |
| `internal_ips.md` | Kubernetes manifests or Docker Compose files that reference those IPs by hostname/IP |
| `.vscode/mcp.json` | `README.md` MCP Servers section |
| `recyclarr/recyclarr.yaml` | `recyclarr/secrets.yaml.template` (if new secret keys are referenced) |
| Talos machine configs (`kubernetes/talos/`) | `ansible/playbooks/bootstrap-talos-k8s-cluster.yaml`; `ansible/scripts/bootstrap-talos-cluster.sh` |
| Add/rename a NixOS ISO definition | `.github/workflows/build-nixos-isos.yaml` matrix list; `nixos/isos/` directory |
| `diagrams/homelab.drawio` | PNG export is auto-generated via CI (`drawio-export.yaml`) — no manual update needed |
