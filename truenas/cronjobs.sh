## Zpool Trimming
zpool trim FranzHopper

## Rclone backup media to Azure Blob Storage (Every 3 months)
rclone sync /mnt/X.A.N.A./media azureblobcrypt:truenasbackup --filter-from /mnt/X.A.N.A./media/other/rclone-azureblob.rules --transfers 8 --checkers 16 --retries 3 --low-level-retries 10 --config /mnt/X.A.N.A./media/other/rclone.conf --fast-list --azureblob-access-tier cool --log-level INFO --log-file /tmp/rclone-azureblob.log

## Rclone Media Backup to OneDrive (Every 3 Months)
rclone sync /mnt/X.A.N.A./media onedrive:truenasbackup --filter-from /mnt/X.A.N.A./media/other/rclone-onedrive.rules --transfers 8 --checkers 16 --retries 3 --low-level-retries 10 --config /mnt/X.A.N.A./media/other/rclone.conf --fast-list --log-level INFO --log-file /tmp/rclone-onedrive.log

## Rclone Appdata Backup to OneDrive
rclone sync /mnt/FranzHopper/appdata onedrive:appdatabackup --transfers 8 --checkers 16 --retries 3 --low-level-retries 10 --config /mnt/X.A.N.A./media/other/rclone.conf --fast-list --log-level INFO --log-file /tmp/rclone-onedrive-appdata.log

## Backup Truenas Config
/mnt/X.A.N.A./truenasconfig-backup/backupscript.sh