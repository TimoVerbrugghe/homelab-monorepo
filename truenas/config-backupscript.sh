#!/bin/sh
BACKUPFOLDER="/mnt/X.A.N.A./truenasconfig-backup/backups"
FILENAME="$(hostname -s)-TrueNAS-SCALE-$(cut -d' ' -f1 /etc/version)-$(date +%Y%m%d%I%M%S).tar"
mkdir -p $BACKUPFOLDER
tar -cf $BACKUPFOLDER/$FILENAME --directory=/data freenas-v1.db pwenc_secret
echo "Backup $FILENAME created"
find $BACKUPFOLDER/*.tar -mtime +30 -exec rm {} \;