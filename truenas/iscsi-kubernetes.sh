#!/usr/bin/env bash
set -euo pipefail

# Copy each command separately into TrueNAS; do not run this file as a script.
# Replace the token placeholder locally; never commit the real token.

# Startup: POSTINIT, 960-second task timeout. Dispatch Scale Up to restore workloads.
# Retry for up to 900 seconds while external dependencies recover.
curl --retry 60 --retry-all-errors --retry-delay 10 --retry-max-time 900 --connect-timeout 10 --max-time 20 --fail-with-body -sS -X POST -H 'Accept: application/vnd.github+json' -H 'Authorization: Bearer <GITHUB_TOKEN>' -H 'X-GitHub-Api-Version: 2022-11-28' https://api.github.com/repos/TimoVerbrugghe/homelab-monorepo/actions/workflows/iscsi-kubernetes.yaml/dispatches -d '{"ref":"main","inputs":{"action":"Scale Up"}}'

# Shutdown: SHUTDOWN, 240-second task timeout. Dispatch Scale Down before NAS stops.
# Allow three retries after the initial attempt, with a 180-second retry ceiling.
curl --retry 3 --retry-all-errors --retry-delay 5 --retry-max-time 180 --connect-timeout 10 --max-time 20 --fail-with-body -sS -X POST -H 'Accept: application/vnd.github+json' -H 'Authorization: Bearer <GITHUB_TOKEN>' -H 'X-GitHub-Api-Version: 2022-11-28' https://api.github.com/repos/TimoVerbrugghe/homelab-monorepo/actions/workflows/iscsi-kubernetes.yaml/dispatches -d '{"ref":"main","inputs":{"action":"Scale Down"}}'
