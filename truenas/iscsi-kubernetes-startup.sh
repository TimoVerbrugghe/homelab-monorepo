#!/bin/sh

# TrueNAS iSCSI Kubernetes Startup Script
# This script scales up deployments using iSCSI volumes after startup

set -e

KUBECONFIG_PATH="/mnt/FranzHopper/secrets"
KUBECONFIG_FILE="$KUBECONFIG_PATH/kubeconfig"

# Array of workloads to scale up (format: "namespace/type/name/replicas")
# type can be: deployment, statefulset, daemonset
WORKLOADS="
mediaplayback/deployment/plex/1
mediaplayback/deployment/jellyfin/1
mediaplayback/deployment/ersatztv/1
"

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

# kubectl wrapper function
kubectl() {
    docker run --rm \
        -v "$KUBECONFIG_FILE:/root/.kube/config:ro" \
        alpine/kubectl \
        "$@"
}

# Check if kubeconfig exists
if [ ! -f "$KUBECONFIG_FILE" ]; then
    log "ERROR: Kubeconfig file not found at $KUBECONFIG_FILE"
    exit 1
fi

log "Starting iSCSI deployment startup sequence..."

# Wait for system to stabilize
log "Waiting for system to stabilize (30 seconds)..."
sleep 30

# Scale up each workload
log "Scaling up workloads with iSCSI volumes..."
for workload in $WORKLOADS; do
    if [ -n "$workload" ]; then
        NAMESPACE=$(echo "$workload" | cut -d'/' -f1)
        TYPE=$(echo "$workload" | cut -d'/' -f2)
        NAME=$(echo "$workload" | cut -d'/' -f3)
        REPLICAS=$(echo "$workload" | cut -d'/' -f4)
        
        log "Scaling up $TYPE: $NAMESPACE/$NAME to $REPLICAS replicas"
        kubectl scale "$TYPE" "$NAME" -n "$NAMESPACE" --replicas="$REPLICAS"
        
        if [ $? -eq 0 ]; then
            log "Successfully scaled up $NAMESPACE/$NAME"
        else
            log "WARNING: Failed to scale up $NAMESPACE/$NAME"
        fi
    fi
done

log "iSCSI deployment startup sequence completed."
