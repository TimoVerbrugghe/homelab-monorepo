# Vaultwarden Kubernetes Deployment

This folder contains resources for deploying **Vaultwarden** in your Kubernetes cluster.

## Contents

- **Deployment files** for Vaultwarden.
- **bitwarden-restore.yaml**: A Kubernetes Job manifest to restore Vaultwarden data from a backup stored in NFS storage.

## Restoring Vaultwarden Data

To restore Vaultwarden files:

1. **Remove the Vaultwarden deployment** from your cluster.  
    *Ensure no Vaultwarden containers are running during the restore process.*

2. **Apply `bitwarden-restore.yaml`**:  
    Deploy this manifest to run a one-time Kubernetes Job.  
    The job will:
    - Wipe the Vaultwarden data folder.
    - Restore data from your NFS backup.

3. **Re-deploy Vaultwarden** after the restore is complete.

## Notes

- Always verify backups before restoring.
- Ensure NFS storage is accessible by the restore job.
- Monitor the job logs for any errors during the restore process.
