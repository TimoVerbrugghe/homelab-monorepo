# Vaultwarden Kubernetes Deployment

This folder contains resources for deploying **Vaultwarden** in your Kubernetes cluster.

## Contents

- **Deployment files** for Vaultwarden.
- **bitwarden-backup.yaml**: A Kubernetes CronJob manifest for automated backups to NFS storage.
- **bitwarden-export.yaml**: A Kubernetes CronJob manifest for exporting Vaultwarden data.
- **bitwarden-restore.yaml**: A Kubernetes Job manifest to restore Vaultwarden data from a backup stored in NFS storage.

## Backup & Restore Strategy

Vaultwarden data is backed up automatically via the `bitwarden-backup` CronJob, which runs daily
and exports data to NFS storage.

**WARNING**: The restore job (`bitwarden-restore.yaml`) is kept in the repository but NOT
automatically deployed to the cluster. Manually applying this job could lead to data loss if the
backup is incomplete or corrupted. Only use if you understand the risks.

## Restoring Vaultwarden Data

To restore Vaultwarden files manually:

1. **Stop the Vaultwarden deployment** from your cluster.  
   *Ensure no Vaultwarden containers are running during the restore process.*

2. **Apply `bitwarden-restore.yaml` (ONLY IF YOU UNDERSTAND THE RISKS)**:

   ```bash
   kubectl apply -f bitwarden-restore.yaml
   ```

   This will run a one-time Kubernetes Job that restores data from your NFS backup.

3. **Re-deploy Vaultwarden** after the restore is complete.

## Notes

- Always verify backups exist and are intact before attempting restoration.
- Ensure NFS storage is accessible from your cluster nodes.
- Monitor backup job logs regularly to ensure automated backups are running successfully.
