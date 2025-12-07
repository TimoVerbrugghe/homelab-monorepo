# iSCSI Test Deployment

This deployment is used to test iSCSI storage behavior, specifically how livenessProbes react when the iSCSI server becomes unavailable.

## Components

- **Namespace**: `iscsi-test`
- **PersistentVolume**: 10Gi iSCSI volume from `odd.local.timo.be:3260`
- **Test Container**: Alpine-based container that continuously writes to the iSCSI mount

## Test Scenario

1. Deploy the test container with iSCSI storage
2. Container has a livenessProbe that tests storage access every 10 seconds
3. Simulate failure by stopping iSCSI service on `odd.local.timo.be`
4. Observe behavior: liveness probe fails → container restarts → init container may fail with stale mount

## Deploy

```bash
kubectl apply -k .
```

## Monitor

```bash
# Watch pod status
kubectl get pods -n iscsi-test -w

# Check logs
kubectl logs -n iscsi-test -l app=iscsi-test -f

# Describe pod for events
kubectl describe pod -n iscsi-test -l app=iscsi-test
```

## Expected Behavior

When iSCSI server goes down:
1. Liveness probe fails after ~30 seconds (3 failures)
2. Kubernetes restarts the container (NOT the pod)
3. Container restart preserves the stale iSCSI mount
4. Container enters CrashLoopBackOff if mount is broken
