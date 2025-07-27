# A docker container to export your bitwarden vault

This is a docker container that runs a bash script to export your vault & organization vaults to an UNENCRYPTED json file. I'm personally running this container as part of a kubernetes CronJob.

## Usage
Docker container needs the following environment variables

- BW_CLIENTID (Client ID that you get from the api key in your account settings on bitwarden)
- BW_CLIENTSECRET (Client Secret that you get from the api key in your account settings on bitwarden)
- BW_SERVER (URL to your bitwarden server)
- BW_PASSWORD (Your bitwarden password)