#!/bin/sh

# TrueNAS iSCSI Kubernetes Shutdown Script
# This script scales down deployments using iSCSI volumes before shutdown
# to prevent data corruption

set -e

KUBECONFIG_PATH="/mnt/FranzHopper/secrets/kubernetes"
KUBECONFIG_FILE="$KUBECONFIG_PATH/kubeconfig"

# Array of workloads to scale down (format: "namespace/type/name")
# type can be: deployment, statefulset, daemonset
WORKLOADS="
mediaplayback/deployment/plex
mediaplayback/deployment/jellyfin
mediaplayback/deployment/ersatztv
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

log "Starting iSCSI deployment shutdown sequence..."

# Scale down each workload
log "Scaling down workloads with iSCSI volumes..."
for workload in $WORKLOADS; do
    if [ -n "$workload" ]; then
        NAMESPACE=$(echo "$workload" | cut -d'/' -f1)
        TYPE=$(echo "$workload" | cut -d'/' -f2)
        NAME=$(echo "$workload" | cut -d'/' -f3)
        
        log "Scaling down $TYPE: $NAMESPACE/$NAME"
        kubectl scale "$TYPE" "$NAME" -n "$NAMESPACE" --replicas=0
        
        if [ $? -eq 0 ]; then
            log "Successfully scaled down $NAMESPACE/$NAME"
        else
            log "WARNING: Failed to scale down $NAMESPACE/$NAME"
        fi
    fi
done

# Wait for pods to terminate
log "Waiting for pods to terminate (30 seconds)..."
sleep 30

log "iSCSI deployment shutdown sequence completed."
