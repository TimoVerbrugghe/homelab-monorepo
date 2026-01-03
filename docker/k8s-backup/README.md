# k8s-backup Docker Container

This Docker container is designed for use in a homelab environment to automate backups of Kubernetes deployments that utilize hostPath volumes for persistent storage.

## Overview

- **Purpose:** Backup data from deployments using hostPath volumes.
- **How it works:** The container will tar the entire contents of the `/appdata` directory (mounted from the host) and copy it to the `/backup` directory (which can be a remote location, such as an NFS server). It will give the tar file the name `BACKUP_NAME-backup-currentdate.tar.gz` (`BACKUP_NAME` is an environment variable that you can set)
- **Deployment:** Intended to be run as a Kubernetes CronJob for scheduled, automated backups.

## Usage

1. **Mount Volumes:**
    - `/appdata`: Source directory containing data to back up.
    - `/backup`: Destination directory for backups (can be a remote mount).

2. **Example Kubernetes CronJob:**

    ```yaml
    apiVersion: batch/v1
    kind: CronJob
    metadata:
      name: k8s-backup
    spec:
      schedule: "0 2 * * *" # Runs daily at 2 AM
      jobTemplate:
         spec:
            template:
              spec:
                 containers:
                    - name: backup
                      image: ghcr.io/timoverbrugghe/k8s-backup:latest
                      env:
                        - name: BACKUP_NAME
                          value: "name-of-application" 
                      volumeMounts:
                         - name: appdata
                            mountPath: /appdata
                         - name: backup
                            mountPath: /backup
                 restartPolicy: OnFailure
                 volumes:
                    - name: appdata
                      hostPath:
                         path: /path/on/host/to/appdata
                    - name: backup
                      nfs:
                         server: nfs.example.com
                         path: /remote/backup/location
    ```

## Notes

- Ensure the container has the necessary permissions to read from `/appdata` and write to `/backup`.
- This can be used together with k8s-restore docker container from this repo
