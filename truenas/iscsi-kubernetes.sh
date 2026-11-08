#!/usr/bin/env bash
set -euo pipefail

curl --retry 60 --retry-all-errors --retry-delay 10 --retry-max-time 900 --connect-timeout 10 --max-time 20 --fail-with-body -sS -X POST -H 'Accept: application/vnd.github+json' -H 'Authorization: Bearer <GITHUB_TOKEN>' -H 'X-GitHub-Api-Version: 2022-11-28' https://api.github.com/repos/TimoVerbrugghe/homelab-monorepo/actions/workflows/iscsi-kubernetes.yaml/dispatches -d '{"ref":"main","inputs":{"action":"Scale Up"}}'

curl --retry 3 --retry-all-errors --retry-delay 5 --retry-max-time 180 --connect-timeout 10 --max-time 20 --fail-with-body -sS -X POST -H 'Accept: application/vnd.github+json' -H 'Authorization: Bearer <GITHUB_TOKEN>' -H 'X-GitHub-Api-Version: 2022-11-28' https://api.github.com/repos/TimoVerbrugghe/homelab-monorepo/actions/workflows/iscsi-kubernetes.yaml/dispatches -d '{"ref":"main","inputs":{"action":"Scale Down"}}'
