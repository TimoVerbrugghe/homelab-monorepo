#!/usr/bin/env bash
set -euo pipefail

# Usage: GITHUB_TOKEN=<token> bash truenas/iscsi-kubernetes.sh 'Scale Up'|'Scale Down'
# TrueNAS: Scale Up at POSTINIT (960s timeout), Scale Down at SHUTDOWN (240s timeout).
if [[ $# -ne 1 ]] || [[ "$1" != "Scale Up" && "$1" != "Scale Down" ]]; then
  printf "Usage: %s 'Scale Up'|'Scale Down'\n" "$0" >&2
  exit 2
fi

: "${GITHUB_TOKEN:?Set GITHUB_TOKEN to a token with Actions write permission for this repository}"

case "$1" in
  "Scale Up")
    curl --retry 60 --retry-all-errors --retry-delay 10 --retry-max-time 900 --connect-timeout 10 --max-time 20 --fail-with-body -sS -X POST -H 'Accept: application/vnd.github+json' -H "Authorization: Bearer $GITHUB_TOKEN" -H 'X-GitHub-Api-Version: 2022-11-28' https://api.github.com/repos/TimoVerbrugghe/homelab-monorepo/actions/workflows/iscsi-kubernetes.yaml/dispatches -d '{"ref":"main","inputs":{"action":"Scale Up"}}'
    ;;
  "Scale Down")
    curl --retry 3 --retry-all-errors --retry-delay 5 --retry-max-time 180 --connect-timeout 10 --max-time 20 --fail-with-body -sS -X POST -H 'Accept: application/vnd.github+json' -H "Authorization: Bearer $GITHUB_TOKEN" -H 'X-GitHub-Api-Version: 2022-11-28' https://api.github.com/repos/TimoVerbrugghe/homelab-monorepo/actions/workflows/iscsi-kubernetes.yaml/dispatches -d '{"ref":"main","inputs":{"action":"Scale Down"}}'
    ;;
esac
