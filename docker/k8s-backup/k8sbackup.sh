#!/bin/sh
set -e

BACKUP_FILENAME="$BACKUP_NAME-backup-$(date +%Y%m%d%H%M%S).tar.gz"

# Tar the contents of /appdata into /backup
tar czf "/appdata/${BACKUP_FILENAME}" -C /backup .

# Only keep the last 3 backups
# This will remove the oldest backups, keeping the 3 most recent ones
ls -1t /backup/$BACKUP_NAME-backup-*.tar.gz | tail -n +4 | xargs -r rm --