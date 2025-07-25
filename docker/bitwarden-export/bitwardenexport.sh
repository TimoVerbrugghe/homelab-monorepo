#!/bin/bash

## Configuration variables ##

ENV_FILE=/environment.sh
APPDATAFOLDER=/appdata
EXPORTFOLDER="$APPDATAFOLDER"/export
EXPORTFILE="$EXPORTFOLDER/vaultbackup_$(date '+%d%m%Y').json"

## Starting Backup ##
printf "\nStarting backup of bitwarden. Current date & time is $(date).\n"

## Loading Variables ##
printf "\nLoading Client ID, Client Secret, Server and Password variables.\n"

source <(cat "$ENV_FILE" | grep "BW_CLIENTID")
source <(cat "$ENV_FILE" | grep "BW_CLIENTSECRET")
source <(cat "$ENV_FILE" | grep "BW_SERVER")
source <(cat "$ENV_FILE" | grep "BW_PASSWORD")

## Connecting to Bitwarden Server ##
printf "\nConnecting to bitwarden server $BW_SERVER.\n"
bw config server "$BW_SERVER"
bw login --apikey

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
        orgid=$(printf "$ORGS" | jq -r --argjson index $i '.[$index] | .id')
        bw export --format json --organizationid $orgid --session "$BW_SESSION" --output "$EXPORTFOLDER/orgbackup_$orgname_$(date '+%d%m%Y').json"
    done
else
    printf "\nNo organizations found.\n"
fi

## Cleanup ##
# Keep only the last 3 vaultbackup_ and orgbackup_ files based on modification time
find "$EXPORTFOLDER" -type f -name 'vaultbackup_*.json' -printf '%T@ %p\n' | sort -nr | awk 'NR>3 {print $2}' | xargs -r rm --
find "$EXPORTFOLDER" -type f -name 'orgbackup_*.json' -printf '%T@ %p\n' | sort -nr | awk 'NR>3 {print $2}' | xargs -r rm --

## Closing out ##
printf "\nBackup done. Locking vault & logging out.\n"
bw lock
bw logout

exit