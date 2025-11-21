## Backup Truenas Config
/mnt/X.A.N.A./truenasconfig-backup/backupscript.sh

# Short S.M.A.R.T. check on all devices (every day)
midclt call disk.smart_test SHORT '["*"]'

# Long S.M.A.R.T. check on all devices (every 4 months)
midclt call disk.smart_test LONG '["*"]'

# Clean up docker resources (orphaned images, unused networks, etc...)
docker system prune -a -f