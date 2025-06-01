## SpotDL - Download all user saved albums
docker run --rm -v /mnt/FranzHopper/appdata/spotdl:/root/.spotdl -v /mnt/X.A.N.A./media/spotdl:/music spotdl/spotify-downloader download all-user-saved-albums --config --user-auth --output "{album}/{artists} - {title}.{output-ext}"

## SpotDL - Download all user liked songs
docker run --rm -v /mnt/FranzHopper/appdata/spotdl:/root/.spotdl -v /mnt/X.A.N.A./media/spotdl:/music spotdl/spotify-downloader download saved --config --user-auth --output "{list-name}/{artists} - {title}.{output-ext}"

## Zpool Trimming
zpool trim FranzHopper

## Rclone Sync - Azure Blob Storage
rclone sync /mnt/X.A.N.A./media azureblobcrypt:truenasbackup --filter-from /mnt/X.A.N.A./media/other/rclone-azureblob.rules --transfers 8 --checkers 16 --retries 3 --low-level-retries 10 --config /mnt/X.A.N.A./media/other/rclone.conf --fast-list --azureblob-access-tier cool --log-level INFO --log-file /tmp/rclone-azureblob.log

## Rclone Sync - OneDrive Media
rclone sync /mnt/X.A.N.A./media onedrive:truenasbackup --filter-from /mnt/X.A.N.A./media/other/rclone-onedrive.rules --transfers 8 --checkers 16 --retries 3 --low-level-retries 10 --config /mnt/X.A.N.A./media/other/rclone.conf --fast-list --log-level INFO --log-file /tmp/rclone-onedrive.log

## Rclone Sync - OneDrive Config Folder
rclone sync /mnt/FranzHopper/appdata onedrive:appdatabackup --transfers 8 --checkers 16 --retries 3 --low-level-retries 10 --config /mnt/X.A.N.A./media/other/rclone.conf --fast-list --log-level INFO --log-file /tmp/rclone-onedrive-appdata.log

## Config Backup
/mnt/X.A.N.A./truenasconfig-backup/backupscript.sh