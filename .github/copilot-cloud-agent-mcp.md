# Copilot Cloud Agent — MCP Server Configuration

This document tracks the MCP server configuration intended for **GitHub Copilot
coding agent (cloud execution)**, as distinct from the local VS Code MCP
configuration in [.vscode/mcp.json](../.vscode/mcp.json).

## Why this can't be applied automatically

GitHub does **not** currently expose a REST/GraphQL API or `gh` CLI command to
write a repository's Copilot cloud agent MCP configuration. It is a **UI-only
setting**:

> Repository → **Settings → Copilot → Coding agent → MCP configuration**

Paste the JSON below into that text box and click **Save**. No tool
(including the GitHub MCP server) can perform this write on your behalf.

Secrets referenced by the config must be created separately under:

> Repository → **Settings → Secrets and variables → Copilot**

(a distinct secret store from Actions/Codespaces/Dependabot secrets). Only
secrets/variables prefixed `COPILOT_MCP_` are exposed to MCP server
processes.

## Tailnet connectivity for the cloud agent

The Copilot coding agent runs its **setup steps**
([.github/workflows/copilot-setup-steps.yaml](workflows/copilot-setup-steps.yaml))
in a GitHub-hosted Actions runner before the agent session starts. That
workflow now joins the `pony-godzilla` tailnet using the
[`tailscale/github-action`](https://github.com/tailscale/github-action) with
an OAuth client (`TAILSCALE_OAUTH_CLIENT_ID` / `TAILSCALE_OAUTH_CLIENT_SECRET`
**Actions** secrets — the same secrets already used by
[rotate-cluster-credentials.yaml](workflows/rotate-cluster-credentials.yaml)
and other workflows in this repo; not `COPILOT_MCP_*`, since this step runs
as a normal workflow, not inside an MCP server process) and
`accept-routes: true`, so that LAN subnet routes advertised into the tailnet
(the homelab's `10.10.10.0/24` network, per
[internal_ips.md](../internal_ips.md)) become reachable for the remainder of
the agent's ephemeral environment.

This means MCP servers that point at homelab hosts can now be reached
directly, either by:

- **LAN IP** (e.g. `10.10.10.1` for UniFi, `10.10.10.33:6443` for the
  Kubernetes API server), for hosts documented in
  [internal_ips.md](../internal_ips.md), or
- **Tailscale MagicDNS name** (`<host>.pony-godzilla.ts.net`), for hosts that
  are themselves tailnet nodes — confirmed reachable for Proxmox and
  Portainer, which don't have a dedicated LAN IP entry in
  [internal_ips.md](../internal_ips.md), and used for Home Assistant too
  (`homeassistant.pony-godzilla.ts.net`) even though it has a LAN IP entry
  there (`10.10.10.28`), per explicit preference for MagicDNS over LAN IP.

Either form resolves once the runner has joined the tailnet with
`accept-routes: true`. `*.local` mDNS names and public hostnames like
`*.kubernetes.timo.be` / `*.local.timo.be` from the local VS Code config do
**not** resolve on a GitHub-hosted runner and must not be reused as-is.

`copilot-setup-steps.yaml` also now installs `uv`/`uvx`
(`curl -LsSf https://astral.sh/uv/install.sh | sh`), which is required to run
the `portainer`, `unifi-network`, and `proxmox` MCP servers — all three are
distributed as `uvx`-launched Python packages and are not preinstalled on
GitHub-hosted runners.

## Scope decision

[.vscode/mcp.json](../.vscode/mcp.json) defines 8 servers. Of these:

- `siderolabs-docs` and `cloudflare` are public HTTP MCP endpoints — reachable
  from GitHub-hosted cloud agent runners with no extra networking.
- `homeAssistant`, `portainer`, `unifi-network`, and `proxmox` point at hosts
  only reachable on the homelab's local network / Tailscale tailnet. Now that
  `copilot-setup-steps.yaml` joins the tailnet with `accept-routes: true`,
  these are **enabled**, addressed by LAN IP or tailnet MagicDNS name (see
  above) instead of the `*.local` / `*.kubernetes.timo.be` /
  `*.local.timo.be` hostnames used locally. Home Assistant is itself a
  tailnet node, so it is addressed by its MagicDNS name
  (`homeassistant.pony-godzilla.ts.net`) rather than its LAN IP.
- `kubernetes` (`mcp-server-kubernetes`) is now **enabled**. It needs a
  kubeconfig pointing at the cluster's API server, provided as an ambient
  file on disk (the npx package has no argument-based host/token config).
  `copilot-setup-steps.yaml` writes it from the repository's existing
  `KUBECONFIG` **Actions** secret (the same secret used by
  [deploy-k8s-resource.yaml](workflows/deploy-k8s-resource.yaml) and
  [iscsi-kubernetes.yaml](workflows/iscsi-kubernetes.yaml)) to
  `$HOME/.kube/config` before the agent session starts.

## MCP configuration JSON (paste into the GitHub UI)

```json
{
  "mcpServers": {
    "siderolabs-docs": {
      "type": "http",
      "url": "https://docs.siderolabs.com/mcp",
      "tools": ["*"]
    },
    "cloudflare": {
      "type": "http",
      "url": "https://mcp.cloudflare.com/mcp",
      "tools": ["*"]
    },
    "homeAssistant": {
      "type": "http",
      "url": "http://homeassistant.pony-godzilla.ts.net:8123/api/mcp",
      "headers": {
        "Authorization": "Bearer $COPILOT_MCP_HA_TOKEN"
      },
      "tools": ["*"]
    },
    "portainer": {
      "type": "local",
      "command": "uvx",
      "args": ["mcp-portainer"],
      "env": {
        "PORTAINER_URL": "https://portainer.pony-godzilla.ts.net:9443",
        "PORTAINER_API_KEY": "$COPILOT_MCP_PORTAINER_TOKEN"
      },
      "tools": ["*"]
    },
    "unifi-network": {
      "type": "local",
      "command": "uvx",
      "args": ["unifi-network-mcp@latest"],
      "env": {
        "UNIFI_HOST": "10.10.10.1",
        "UNIFI_USERNAME": "unifimcp",
        "UNIFI_PASSWORD": "$COPILOT_MCP_UNIFI_PASSWORD",
        "UNIFI_VERIFY_SSL": "true"
      },
      "tools": ["*"]
    },
    "proxmox": {
      "type": "local",
      "command": "uvx",
      "args": ["proxmox-mcp-plus"],
      "env": {
        "PROXMOX_HOST": "proxmox.pony-godzilla.ts.net",
        "PROXMOX_USER": "root@pam",
        "PROXMOX_TOKEN_NAME": "mcp-token",
        "PROXMOX_TOKEN_VALUE": "$COPILOT_MCP_PROXMOX_TOKEN_VALUE",
        "PROXMOX_PORT": "443",
        "PROXMOX_VERIFY_SSL": "true"
      },
      "tools": ["*"]
    },
    "kubernetes": {
      "type": "local",
      "command": "npx",
      "args": ["mcp-server-kubernetes"],
      "tools": ["*"]
    }
  }
}
```

> **Note:** UniFi (`10.10.10.1`) is a LAN IP confirmed against
> [internal_ips.md](../internal_ips.md). Home Assistant, Portainer, and
> Proxmox have no dedicated LAN IP entry there, so their tailnet MagicDNS
> names (`homeassistant.pony-godzilla.ts.net`,
> `portainer.pony-godzilla.ts.net`, `proxmox.pony-godzilla.ts.net`) are used
> instead — these were resolved and confirmed to have an assigned tailnet
> address, but end-to-end reachability from a GitHub-hosted runner has not
> been tested. Verify with a real Copilot agent run (or a manual `curl`/`nc`
> check from a machine on the same tailnet with `tag:ci`-scoped access)
> before relying on this in production. `kubernetes` is reached via the
> cluster's LAN API server address (`10.10.10.33:6443`) baked into the
> kubeconfig itself, not via an MCP server argument.

Required Copilot Agents secrets (create under **Settings → Secrets and
variables → Copilot**, not Actions):

| Secret name | Source value |
| ------------- | ------------- |
| `COPILOT_MCP_HA_TOKEN` | Home Assistant long-lived access token |
| `COPILOT_MCP_PORTAINER_TOKEN` | Portainer administrator API token |
| `COPILOT_MCP_UNIFI_PASSWORD` | UniFi local admin password |
| `COPILOT_MCP_PROXMOX_TOKEN_VALUE` | Proxmox API token value |

Required repository **Actions** secrets (create under **Settings → Secrets
and variables → Actions** — used by `copilot-setup-steps.yaml` itself, not
by MCP server processes). These already exist in this repository and are
shared with other workflows:

| Secret name | Source value | Also used by |
| ------------- | ------------- | ------------- |
| `TAILSCALE_OAUTH_CLIENT_ID` | Tailscale OAuth client ID (tag-scoped, e.g. `tag:ci`) | — |
| `TAILSCALE_OAUTH_CLIENT_SECRET` | Tailscale OAuth client secret | — |
| `KUBECONFIG` | Kubeconfig for the `sectorfive` cluster's API server | [rotate-cluster-credentials.yaml](workflows/rotate-cluster-credentials.yaml), [deploy-k8s-resource.yaml](workflows/deploy-k8s-resource.yaml), [iscsi-kubernetes.yaml](workflows/iscsi-kubernetes.yaml) |

The Tailscale OAuth client should be scoped (via an ACL tag such as
`tag:ci`) to only the access the cloud agent actually needs — avoid reusing
a broad/admin-scoped OAuth client for this purpose. `KUBECONFIG` currently
grants the same access as the other workflows above (cluster-admin); scoping
it down to a narrower role for the cloud agent specifically is a possible
future hardening step (see Open follow-ups).

`tailscale` (the `@hexsleeves/tailscale-mcp-server` MCP server from
[.vscode/mcp.json](../.vscode/mcp.json)) is intentionally omitted from the
cloud agent scope: it manages Tailscale ACLs/devices via Tailscale's cloud
API and does **not** create tailnet connectivity for other processes in the
same environment. Tailnet connectivity for the *other* MCP servers is
instead provisioned once, up front, by `copilot-setup-steps.yaml` joining
the tailnet directly — see above.

## Open follow-ups

1. Validate real end-to-end reachability of `homeassistant.pony-godzilla.ts.net`,
   `10.10.10.1` (UniFi), `portainer.pony-godzilla.ts.net`,
   `proxmox.pony-godzilla.ts.net`, and `10.10.10.33:6443` (kubernetes) from an
   actual Copilot coding agent run — the addresses above were derived from
   repo docs and MagicDNS lookups from a developer machine already on the
   tailnet, not from a live cloud-agent test.
2. Consider minting a scoped ServiceAccount/RBAC role for the cloud agent's
   `kubernetes` MCP server instead of reusing the same cluster-admin
   `KUBECONFIG` secret used by deployment workflows.
3. If/when GitHub ships a write API for the Copilot MCP configuration
   setting, this doc's JSON can be applied programmatically instead of via
   the UI.
4. Consider allowlisting specific read-only tools per server instead of
   `"tools": ["*"]`, per GitHub's security recommendation.
