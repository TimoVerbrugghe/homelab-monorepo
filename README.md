# homelab-monorepo

<!-- AUTO-GENERATED BADGES - DO NOT EDIT MANUALLY -->
[![View Architecture Diagram](https://img.shields.io/badge/View%20Diagram-draw.io-blue?logo=diagramsdotnet&logoColor=white)](https://app.diagrams.net/?url=https://raw.githubusercontent.com/TimoVerbrugghe/homelab-monorepo/main/diagrams/homelab.drawio)
![Kubernetes Manifests](https://img.shields.io/badge/kubernetes%20manifests-206-326CE5?logo=kubernetes&logoColor=white)
![Docker Compose](https://img.shields.io/badge/docker%20compose-15-2496ED?logo=docker&logoColor=white)
![Ansible Playbooks](https://img.shields.io/badge/ansible%20playbooks-13-EE0000?logo=ansible&logoColor=white)
![NixOS Machines](https://img.shields.io/badge/nixos%20machines-6-5277C3?logo=nixos&logoColor=white)
![Shell Scripts](https://img.shields.io/badge/shell%20scripts-9-4EAA25?logo=gnubash&logoColor=white)
![GitHub Workflows](https://img.shields.io/badge/github%20workflows-12-2088FF?logo=githubactions&logoColor=white)
![Repo Size](https://img.shields.io/github/repo-size/TimoVerbrugghe/homelab-monorepo)
<!-- END AUTO-GENERATED BADGES -->

This repository contains all my setup files while I'm learning Ansible, Kubernetes, NixOS & others.

Heavily influenced by TechnoTim (<https://github.com/techno-tim>), Christian Lempa (<https://github.com/ChristianLempa/christianlempa>) & the Linux Unplugged team (<https://linuxunplugged.com/>).

## GitHub Workflows Status

![Build NixOS ISOs](https://img.shields.io/github/actions/workflow/status/TimoVerbrugghe/homelab-monorepo/build-nixos-isos.yaml?branch=master&label=build-nixos-isos&logo=githubactions&logoColor=white)
![Check Broken Links](https://img.shields.io/github/actions/workflow/status/TimoVerbrugghe/homelab-monorepo/check-broken-links.yaml?branch=master&label=check-broken-links&logo=githubactions&logoColor=white)
![Deploy K8s Resource](https://img.shields.io/github/actions/workflow/status/TimoVerbrugghe/homelab-monorepo/deploy-k8s-resource.yaml?branch=master&label=deploy-k8s-resource&logo=githubactions&logoColor=white)
![DrawIO Export](https://img.shields.io/github/actions/workflow/status/TimoVerbrugghe/homelab-monorepo/drawio-export.yaml?branch=master&label=drawio-export&logo=githubactions&logoColor=white)
![iSCSI Kubernetes](https://img.shields.io/github/actions/workflow/status/TimoVerbrugghe/homelab-monorepo/iscsi-kubernetes.yaml?branch=master&label=iscsi-kubernetes&logo=githubactions&logoColor=white)
![Lint Markdown](https://img.shields.io/github/actions/workflow/status/TimoVerbrugghe/homelab-monorepo/lint-markdown.yaml?branch=master&label=lint-markdown&logo=githubactions&logoColor=white)
![Lint YAML/JSON](https://img.shields.io/github/actions/workflow/status/TimoVerbrugghe/homelab-monorepo/lint-yaml-json.yaml?branch=master&label=lint-yaml-json&logo=githubactions&logoColor=white)
![Sync External Skills](https://img.shields.io/github/actions/workflow/status/TimoVerbrugghe/homelab-monorepo/sync-external-skills.yaml?branch=master&label=sync-external-skills&logo=githubactions&logoColor=white)
![Update Badges](https://img.shields.io/github/actions/workflow/status/TimoVerbrugghe/homelab-monorepo/update-badges.yaml?branch=master&label=update-badges&logo=githubactions&logoColor=white)
![Update Talos Machines](https://img.shields.io/github/actions/workflow/status/TimoVerbrugghe/homelab-monorepo/update-talos-machines.yaml?branch=master&label=update-talos-machines&logo=githubactions&logoColor=white)
![Validate Shell Scripts](https://img.shields.io/github/actions/workflow/status/TimoVerbrugghe/homelab-monorepo/validate-shell-scripts.yaml?branch=master&label=validate-shell-scripts&logo=githubactions&logoColor=white)
![Build WinPE Image](https://img.shields.io/github/actions/workflow/status/TimoVerbrugghe/homelab-monorepo/build-winpe-image.yaml?branch=master&label=build-winpe-image&logo=githubactions&logoColor=white)

## My Homelab

I have the following machines & VMs with a brief overview of services they run. All VMs in Proxmox run NixOS.

- TheFactory
  - TrueNAS Scale
  - Docker services (see docker/truenas/ folder)

- Proxmox cluster (Lyoko)
  - Forest Sector
    - Yumi (kubernetes node with local storage, HA, can be live migrated)
      - Bitwarden
      - Mealie
      - Portainer
    - William (kubernetes node)
  - Ice Sector
    - Odd (Adguardhome on NixOS)
    - Manta (kubernetes node)
  - Forest Sector
    - Ulrich (Adguardhome on NixOS)
    - Hass (Home Assistant OS)
    - Skidbladnir (kubernetes node)

## Kubernetes cluster

Built using Talos linux. Currently runs several services such as Traefik, Plex, Homepage, Gatus, Adguardhome, ... (check the kubernetes subfolder for all deployments).

Several services are not running in this cluster and remain on separate NixOS VMs or TrueNAS with docker because:

- I don't want to run hyperconverged storage solutions (Longhorn, OpenEBS, etc...) due to the amount of resources it takes & the complexity of the setup.
- I encountered several issues with NFS-backed storage (even with NFSv4) and sqlite databases
  (f.e. with plex & bitwarden) so not an option to use NFS-backed storage in the cluster. For
  Plex & Jellyfin in the kubernetes cluster, I'm using iSCSI backed storage.
- Services that I want HA and do need local storage (portainer, bitwarden, etc...) are running in the Yumi kubernetes node that is HA-enabled in proxmox & can be live migrated.

## MCP Servers

### TrueNAS

[TrueNAS MCP](https://github.com/truenas/truenas-mcp) runs locally over stdio and
connects to TrueNAS over secure WebSocket; nothing is installed on the NAS.
It is an upstream research preview. The initial tool allowlist contains only
`system_info`, `system_health`, and `query_pools`; do not enable management tools
until read-only validation succeeds.

- **Local Agent Host:** root [`.mcp.json`](.mcp.json) uses
  `wss://truenas.local.timo.be:443/websocket`. Install the upstream v0.0.6
  executable for your platform as `truenas-mcp` on `PATH`, verifying its release
  checksum. Export `COPILOT_MCP_TRUENAS_API_KEY` in the host environment;
  [`mcp.env.template`](mcp.env.template) lists the variable but is not auto-loaded.
- **Cloud agent:** [`.github/mcp.json`](.github/mcp.json) uses
  `wss://truenas.pony-godzilla.ts.net:443/websocket`. The
  [setup workflow](.github/workflows/copilot-setup-steps.yaml) installs Linux AMD64
  v0.0.6 with a pinned SHA-256 and verifies its version. Strip the leading `//`
  comments and paste the JSON into **Settings → Copilot → MCP servers**.
  Committing this file does not register the server.
- Add **Agents secret** `COPILOT_MCP_TRUENAS_API_KEY` under the coding agent's
  secrets and variables. Create a dedicated TrueNAS API key with the minimum
  read-only privileges needed for the allowlisted calls, not an administrator key.
  The client allowlist does not replace server-side authorization.
- TLS verification stays enabled. Certificates must match the configured hostname.
  For a private CA or self-signed certificate, set local `TRUENAS_TLS_CA` to a
  trusted PEM file. For cloud setup, optionally add **Actions secret**
  `TRUENAS_TLS_CA_PEM` containing that PEM certificate (never its private key);
  setup adds it to the MCP trust bundle. Do not disable certificate verification.
- Reuse the setup workflow's Tailscale connection. Allow `tag:github-cicd` to
  reach the TrueNAS tailnet node on TCP 443 and ensure MagicDNS resolution works.
  Any Tailscale Serve/reverse proxy must forward `/websocket` with WebSocket
  upgrades to the TrueNAS API. This tailnet address requires no LAN subnet route;
  if switching to a LAN address, approve its advertised route, accept routes on
  the runner, and allow the destination in the tailnet ACLs.
- Setup verifies TLS and the WebSocket upgrade without credentials. To also test
  MCP initialization and a harmless `system_info` call, supply
  `COPILOT_MCP_TRUENAS_API_KEY` as an **Actions secret** available to setup.
  Agents secrets are configured separately. The query output is not logged;
  without the Actions secret the authenticated check explicitly reports a skip.
  After registration, confirm the cloud agent can call `system_info` before
  broadening access. If its firewall blocks the endpoint, allow this specific
  hostname rather than disabling the firewall.

## Future Plans

- Nothing right now. Feel free to suggest other things I might want to do in this setup!

## Contributing

Suggestions, ideas, and improvements are welcome! See [.github/copilot-instructions.md](.github/copilot-instructions.md) for the full guide on how this repo is structured and how to make changes.

Quick checklist before opening a PR:

- YAML passes `yamllint`
- Shell scripts pass `shellcheck`
- Kubernetes manifests include the hardening baseline (see `.github/instructions/kubernetes-deployment-best-practices.instructions.md`)
- No secrets or credentials committed — use `.env.template` patterns
- Maintenance matrix reviewed (see `.github/copilot-instructions.md`)
