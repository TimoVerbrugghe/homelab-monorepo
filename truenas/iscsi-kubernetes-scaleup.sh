∏#!/bin/sh

set -euo pipefail

TOKEN_FILE="/mnt/FranzHopper/secrets/githubtoken"
REPO_OWNER="TimoVerbrugghe"
REPO_NAME="homelab-monorepo"
WORKFLOW_FILE="iscsi-kubernetes.yaml"
REF="master"
WORKLOADS="mediaplayback/deployment/plex/1, mediaplayback/deployment/jellyfin/1, mediaplayback/deployment/ersatztv/1"

if [ ! -f "$TOKEN_FILE" ]; then
  echo "ERROR: GitHub token file not found at $TOKEN_FILE" >&2
  exit 1
fi
TOKEN=$(cat "$TOKEN_FILE")

curl -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $TOKEN" \
  "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/actions/workflows/$WORKFLOW_FILE/dispatches" \
  -d "{\"ref\":\"$REF\",\"inputs\":{\"action\":\"Scale Up\",\"workloads\":\"$WORKLOADS\"}}"
