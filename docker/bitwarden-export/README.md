# A docker container to export your bitwarden vault

This is a docker container that runs a bash script, in a cron schedule that you define, to export your vault & organization vaults to an UNENCRYPTED json file.

## Usage
Docker container needs the following environment variables

- CRON_SCHEDULE (a cron schedule that defines when to backup your bitwarden docker, example: 0 0 1 * * -> every month)
- BW_CLIENTID (Client ID that you get from the api key in your account settings on bitwarden)
- BW_CLIENTSECRET (Client Secret that you get from the api key in your account settings on bitwarden)
- BW_SERVER (URL to your bitwarden server)
- BW_PASSWORD (Your bitwarden password)