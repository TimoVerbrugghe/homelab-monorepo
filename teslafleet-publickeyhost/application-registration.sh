#!/bin/bash
CLIENT_ID=
CLIENT_SECRET=
AUDIENCE="https://fleet-api.prd.eu.vn.cloud.tesla.com"
DOMAIN="tesla.timo.be"

response=$(curl --request POST \
    --header 'Content-Type: application/x-www-form-urlencoded' \
    --data-urlencode 'grant_type=client_credentials' \
    --data-urlencode "client_id=$CLIENT_ID" \
    --data-urlencode "client_secret=$CLIENT_SECRET" \
    --data-urlencode 'scope=openid vehicle_device_data vehicle_cmds vehicle_charging_cmds' \
    --data-urlencode "audience=$AUDIENCE" \
    'https://fleet-auth.prd.vn.cloud.tesla.com/oauth2/v3/token')

access_token=$(echo $response | jq -r .access_token)

curl --location "$AUDIENCE/api/1/partner_accounts" \
--header 'Content-Type: application/json' \
--header "Authorization: Bearer $access_token" \
--data '{
    "domain": "'"$DOMAIN"'"
}'