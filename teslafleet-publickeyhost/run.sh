#!/usr/bin/with-contenv bashio

bashio::log.info "Starting Tesla Fleet Public Key Host Addon..."

# Get the public key from the config options
PUBLIC_KEY=/homeassistant_config/com.tesla.3p.public-key.pem
PRIVATE_KEY=/homeassistant_config/tesla_fleet.key

if [ -z "$PUBLIC_KEY" ]; then
    bashio::log.info "Public key does not exist. Please follow the steps to create a public/private key pair at https://www.home-assistant.io/integrations/tesla_fleet/"
    exit 1
fi

if [ -z "$PRIVATE_KEY" ]; then
    bashio::log.info "Private key does not exist. Please follow the steps to create a public/private key pair at https://www.home-assistant.io/integrations/tesla_fleet/"
    exit 1
fi

# Copy the public key to /.well-known/com.tesla.3p.public-key.pem
mkdir -p /data/.well-known
rm -rf /data/.well-known/com.tesla.3p.public-key.pem
cp $PUBLIC_KEY /data/.well-known/com.tesla.3p.public-key.pem

# Start a simple HTTP server to serve the public key
python3 -m http.server 8000