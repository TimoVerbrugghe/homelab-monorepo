# Restoring Portainer Server from Backup

To restore your Portainer Server from a backup, follow these steps:

1. **Locate Your Backup File**  
    Ensure you have the backup `.tar` file. This file should have been uploaded to the server under `/nfs` as specified in `portainer-server-backup.yaml`.

2. **Deploy a Fresh Portainer Instance**  
    Set up a new Portainer Server instance by using `kustomization.yaml` in this folder

3. **Restore During Setup Wizard**  
    When you access the Portainer web UI for the first time, the setup wizard will prompt you to restore from a backup.  
    - Select the option to restore from backup.
    - Upload the latest `.tar` backup file

4. **Complete the Setup**  
    Follow the remaining steps in the setup wizard to finish restoring your Portainer Server.

**Note:**  
Restoring from backup will overwrite any existing configuration in the new Portainer instance. Always verify the integrity of your backup file before proceeding.
