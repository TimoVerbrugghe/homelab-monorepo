#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
env_file="$repo_root/mvp.env"

if [[ ! -f "$env_file" ]]; then
  printf 'Missing %s. Copy mvp.env.template to mvp.env and fill in the secrets.\n' "$env_file" >&2
  exit 1
fi

set -a
# shellcheck source=../mvp.env.template
source "$env_file"
set +a

required_variables=(
  "COPILOT_MCP_HA_TOKEN=${COPILOT_MCP_HA_TOKEN:-}"
  "COPILOT_MCP_PORTAINER_TOKEN=${COPILOT_MCP_PORTAINER_TOKEN:-}"
  "COPILOT_MCP_PROXMOX_TOKEN_VALUE=${COPILOT_MCP_PROXMOX_TOKEN_VALUE:-}"
  "COPILOT_MCP_TAILSCALE_OAUTH_CLIENT_ID=${COPILOT_MCP_TAILSCALE_OAUTH_CLIENT_ID:-}"
  "COPILOT_MCP_TAILSCALE_OAUTH_CLIENT_SECRET=${COPILOT_MCP_TAILSCALE_OAUTH_CLIENT_SECRET:-}"
  "COPILOT_MCP_UNIFI_PASSWORD=${COPILOT_MCP_UNIFI_PASSWORD:-}"
)

missing=0
for variable in "${required_variables[@]}"; do
  if [[ -z "${variable#*=}" ]]; then
    printf 'Missing MCP secret: %s\n' "${variable%%=*}" >&2
    missing=1
  fi
done
if [[ "$missing" -ne 0 ]]; then
  exit 1
fi

cd -- "$repo_root"
if [[ "$#" -eq 0 ]]; then
  set -- code "$repo_root"
fi
exec "$@"
