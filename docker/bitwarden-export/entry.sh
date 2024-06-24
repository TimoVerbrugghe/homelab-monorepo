#!/bin/sh

printf "\nSetting up environment after container restart (folders, crontab file creation, etc...)\n"

# Create export & log folders
printf "\\nCreating export & log folders\n"
mkdir -p /appdata/export

# create crontab file
printf "\nCreating cron schedule and crontab file\n"
touch /crontab.txt
truncate -s 0 /crontab.txt
printf "$CRON_SCHEDULE /bitwardenexport.sh" >> /crontab.txt

# Put crontab file in place
/usr/bin/crontab /crontab.txt

# Create environment file
printf "\nCreating environment file so that script will run correctly\n"
printenv | sed 's/^\(.*\)$/export \1/g' > /environment.sh
chmod +x /environment.sh

# Run script at startup
printf "\nRunning bitwarden export on container startup\n"
/bitwardenexport.sh

printf "\nStarting cron schedule, next backup will be at your defined cron schedule ($CRON_SCHEDULE)\n"

# start cron
/usr/sbin/crond -f -l 8