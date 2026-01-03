# k8s-restore Docker Container

This container is designed for use in a Kubernetes cluster to automate the restoration of backups to a hostPath volume. It is primarily
intended for homelab environments where deployments use local storage (hostPath) volumes.

## Purpose

- **Restore Backups:** Unpacks the latest `.tar` backup file from the `/backup` directory to the `/appdata` directory.
- **Kubernetes Integration:** Intended to be run as a Kubernetes CronJob.
- **Flexible Storage:** Supports remote backup sources (e.g., NFS server) mounted to `/backup` and restores to a local hostPath volume mounted at `/appdata`.

## Usage

1. **Mount Volumes:**
    - `/backup`: Source directory containing backup `.tar` files (can be an NFS mount).
    - `/appdata`: Target directory for data restoration (should be a hostPath volume).

2. **Operation:**
    - On execution, the container finds the latest `.tar` file in `/backup` and extracts its contents into `/appdata`, overwriting existing data.

## Example Kubernetes CronJob

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: k8s-restore
spec:
  schedule: "0 3 * * *"
  jobTemplate:
     spec:
        template:
          spec:
             containers:
             - name: k8s-restore
                image: ghcr.io/timoverbrugghe/k8s-restore:latest
                volumeMounts:
                - name: backup
                  mountPath: /backup
                - name: appdata
                  mountPath: /appdata
             restartPolicy: OnFailure
             volumes:
             - name: backup
                nfs:
                  server: <nfs-server>
                  path: /path/to/backups
             - name: appdata
                hostPath:
                  path: /path/on/host
```

## Notes

- Ensure the container has the necessary permissions to read from `/backup` and write to `/appdata`.
- Only the latest `.tar` file is restored each run.
