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

## Scope decision

[.vscode/mcp.json](../.vscode/mcp.json) defines 8 servers. Of these:

- `siderolabs-docs` and `cloudflare` are public HTTP MCP endpoints — reachable
  from GitHub-hosted cloud agent runners with no extra networking.
- `homeAssistant`, `portainer`, `unifi-network`, and `proxmox` point at hosts
  only reachable on the homelab's local network / Tailscale tailnet
  (`*.local`, `*.kubernetes.timo.be`, `*.local.timo.be`). GitHub-hosted
  runners have no route to these hosts, so these servers were **excluded**
  from the cloud agent config until Tailscale connectivity is provisioned
  inside the agent's ephemeral environment (e.g. via a
  `copilot-setup-steps.yml` step that installs and authenticates
  `tailscaled`) or the hosts are made reachable another way.
- `kubernetes` (`mcp-server-kubernetes`) needs a kubeconfig pointing at the
  cluster's API server, which is also only reachable via the tailnet/local
  network — excluded for the same reason.

If tailnet connectivity is added later, these 4+1 servers can be reintroduced
using the same translation pattern shown below.

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
    }
  }
}
```

No secrets are required for this initial scope — both servers are public,
unauthenticated HTTP MCP endpoints.

## Deferred servers (reference translation, not yet applied)

These are kept here for when homelab connectivity from the cloud agent is
solved. They are **not currently pasted into the GitHub UI**.

```json
{
  "mcpServers": {
    "homeAssistant": {
      "type": "http",
      "url": "http://homeassistant.local:8123/api/mcp",
      "headers": {
        "Authorization": "Bearer $COPILOT_MCP_HA_TOKEN"
      },
      "tools": ["*"]
    },
    "kubernetes": {
      "type": "local",
      "command": "npx",
      "args": ["mcp-server-kubernetes"],
      "tools": ["*"]
    },
    "portainer": {
      "type": "local",
      "command": "uvx",
      "args": ["mcp-portainer"],
      "env": {
        "PORTAINER_URL": "https://portainer.kubernetes.timo.be",
        "PORTAINER_API_KEY": "$COPILOT_MCP_PORTAINER_TOKEN"
      },
      "tools": ["*"]
    },
    "unifi-network": {
      "type": "local",
      "command": "uvx",
      "args": ["unifi-network-mcp@latest"],
      "env": {
        "UNIFI_HOST": "unifi.local.timo.be",
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
        "PROXMOX_HOST": "proxmox.kubernetes.timo.be",
        "PROXMOX_USER": "root@pam",
        "PROXMOX_TOKEN_NAME": "mcp-token",
        "PROXMOX_TOKEN_VALUE": "$COPILOT_MCP_PROXMOX_TOKEN_VALUE",
        "PROXMOX_PORT": "443",
        "PROXMOX_VERIFY_SSL": "true"
      },
      "tools": ["*"]
    }
  }
}
```

Required Copilot Agents secrets for the deferred set (create under
**Settings → Secrets and variables → Copilot**, not Actions):

| Secret name | Source value |
| ------------- | ------------- |
| `COPILOT_MCP_HA_TOKEN` | Home Assistant long-lived access token |
| `COPILOT_MCP_PORTAINER_TOKEN` | Portainer administrator API token |
| `COPILOT_MCP_UNIFI_PASSWORD` | UniFi local admin password |
| `COPILOT_MCP_PROXMOX_TOKEN_VALUE` | Proxmox API token value |

`tailscale` itself was intentionally omitted from both scopes: it manages
Tailscale ACLs/devices via Tailscale's cloud API and does **not** create tailnet
connectivity for other processes in the same environment, so it wouldn't
solve the reachability problem for the other 4 servers even if added.

## Open follow-ups

1. Decide whether to provision tailnet connectivity inside the Copilot cloud
   agent's ephemeral environment (e.g. `copilot-setup-steps.yml` installing
   and authenticating `tailscaled`) so the deferred servers become usable.
2. If/when GitHub ships a write API for this setting, this doc's JSON can be
   applied programmatically instead of via the UI.
3. Consider allowlisting specific read-only tools per server instead of
   `"tools": ["*"]`, per GitHub's security recommendation.
