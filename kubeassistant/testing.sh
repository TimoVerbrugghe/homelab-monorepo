#!/bin/bash
# deploy-to-ha.sh
HA_HOST="homeassistant.local"
HA_CONFIG="/config"

# Copy component
scp -r /Users/timo/Projects/homelab-monorepo/kubeassistant root@${HA_HOST}:${HA_CONFIG}/custom_components/

# Restart HA
ssh root@${HA_HOST} "ha core restart"