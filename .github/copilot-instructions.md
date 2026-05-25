# Copilot Instructions — Homelab Monorepo

This repository is a personal homelab configuration monorepo. It contains **no compiled application code** — everything is infrastructure-as-code:
Kubernetes manifests (Kustomize), NixOS flake configs, Ansible playbooks, Docker Compose stacks, and shell scripts.

---

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

---

## Maintenance Matrix

When you change a file in column A, you must also review/update the files in column B.

| Changed file / area | Also check / update |
|--------------------|---------------------|
| `kubernetes/<service>/` manifests | `kubernetes/<service>/kustomization.yaml` (resource list); `AGENTS.md` CI table if a new workflow is added |
| Add a new Kubernetes service directory | `kubernetes/README.md`; `AGENTS.md` (CI workflows table if applicable) |
| `nixos/flake.nix` inputs | `nixos/flake.lock` (run `nix flake update`); per-machine configs if module API changed |
| `nixos/modules/<module>.nix` | All `nixos/machines/*/default.nix` files that import that module |
| Add a new NixOS machine | `nixos/flake.nix` (add to `nixosConfigurations`); `ansible/inventory/hosts.yaml` if it needs Ansible |
| `ansible/collections/requirements.yaml` | `AGENTS.md` "Running / Applying Changes" → Ansible section; any CI that installs collections |
| `ansible/inventory/hosts.yaml` | Any playbook targeting changed hosts; `AGENTS.md` Key Machines table |
| Add a new Ansible role | `ansible/collections/requirements.yaml` if it needs a new collection; playbook that uses the role |
| `docker/<host>/<stack>.yaml` | Companion `<stack>.env.template` if new env vars are added; `README.md` service list if applicable |
| Add a new Docker Compose stack | Companion `.env.template`; `AGENTS.md` Adding a Docker Compose Service section |
| `.github/workflows/*.yaml` (new workflow) | `README.md` GitHub Workflows Status badge section; `AGENTS.md` CI Workflows Summary table; `update-badges.yaml` if badge count changes |
| `.github/workflows/update-badges.yaml` | `README.md` badge section (auto-generated, but verify count patterns still match) |
| `internal_ips.md` | Kubernetes manifests or Docker Compose files that reference those IPs by hostname/IP |
| `.vscode/mcp.json` | `README.md` MCP Servers section |
| `recyclarr/recyclarr.yaml` | `recyclarr/secrets.yaml.template` (if new secret keys are referenced) |
| Talos machine configs (`kubernetes/talos/`) | `ansible/playbooks/bootstrap-talos-k8s-cluster.yaml`; `ansible/scripts/bootstrap-talos-cluster.sh` |
| Add/rename a NixOS ISO definition | `.github/workflows/build-nixos-isos.yaml` matrix list; `nixos/isos/` directory |
| `diagrams/homelab.drawio` | PNG export is auto-generated via CI (`drawio-export.yaml`) — no manual update needed |
