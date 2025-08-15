#!/bin/bash

## Configuration variables ##

EXPORTFOLDER=/backup
EXPORTFILE="$EXPORTFOLDER/vaultbackup_$(date +%Y%m%d%H%M%S).json"

## Starting Backup ##
printf "\nStarting backup of bitwarden. Current date & time is $(date).\n"

## Loading Variables ##
printf "\nLoading Client ID, Client Secret, Server and Password variables.\n"

printf "\nLoading Application ID variable (if it was set).\n"
if [[ -n "$BW_APPID" ]]; then
    CONFIG_DIR="/root/.config/Bitwarden CLI"
    CONFIG_FILE="$CONFIG_DIR/data.json"
    mkdir -p "$CONFIG_DIR"
    echo "{\"global_applicationId_appId\": \"$BW_APPID\"}" > "$CONFIG_FILE"
fi

## Connecting to Bitwarden Server ##
printf "\nConnecting to bitwarden server $BW_SERVER.\n"
bw config server "$BW_SERVER"
bw login --apikey

# The following will look for an environment variable BW_PASSWORD. If BW_PASSWORD is non-empty and has correct values, the CLI will successfully unlock and return a session key. See https://bitwarden.com/help/article/cli/#unlock
BW_SESSION=$(bw unlock --raw --passwordenv BW_PASSWORD)
bw sync

## Exporting vault ##
printf "\nExporting user vault.\n"
bw export --format json --session "$BW_SESSION" --output "$EXPORTFILE"

## Exporting organizations ##
printf "\nGetting list of all organizations.\n"
ORGS=$(bw list organizations --session $BW_SESSION)
ORGLENGTH=$(printf "$ORGS" | jq '. | length');

if [[ $ORGLENGTH -gt 0 ]]
then
    for ((i = 0; i <= $ORGLENGTH - 1; i++)); do
        orgname=$(printf "$ORGS" | jq -r --argjson index $i '.[$index] | .name')
        printf "\nExporting vault for organization $orgname\n"
        # Sanitize orgname for use in filename (replace spaces and special chars with underscores)
        safe_orgname=$(echo "$orgname" | tr -cs '[:alnum:]' '_' | tr '[:upper:]' '[:lower:]')
        orgid=$(printf "$ORGS" | jq -r --argjson index $i '.[$index] | .id')
        bw export --format json --organizationid $orgid --session "$BW_SESSION" --output "$EXPORTFOLDER/orgbackup_${safe_orgname}_$(date +%Y%m%d%H%M%S).json"
    done
else
    printf "\nNo organizations found.\n"
fi

## Cleanup ##
# Keep only the last 3 vaultbackup_ and orgbackup_ files based on modification time
printf "\nCleaning up old backups (if needed).\n"
find "$EXPORTFOLDER" -maxdepth 1 -name 'vaultbackup_*.json' -type f -print0 | xargs -0 ls -t 2>/dev/null | tail -n +4 | xargs -r rm --

# Calculate how many orgbackup_ files to keep: 3 per organization
ORG_KEEP_COUNT=$((ORGLENGTH * 3))
if [[ $ORG_KEEP_COUNT -gt 0 ]]; then
    find "$EXPORTFOLDER" -maxdepth 1 -name 'orgbackup_*.json' -type f -print0 | xargs -0 ls -t 2>/dev/null | tail -n +$((ORG_KEEP_COUNT + 1)) | xargs -r rm --
else
     printf "\nNo organizations found. Skipping cleanup of old organization backups.\n"
fi

## Closing out ##
printf "\nBackup done. Locking vault & logging out.\n"
bw lock
bw logout

exit