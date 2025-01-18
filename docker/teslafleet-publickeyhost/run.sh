#!/usr/bin/with-contenv bashio

bashio::log.info "Starting Tesla Fleet Public Key Host Addon..."

# Get the public key from the config options
CONFIG_PATH=/data/options.json
PUBLIC_KEY="$(bashio::config 'publickey')"

if [ -z "$PUBLIC_KEY" ]; then
    bashio::log.info "Public key is empty. Please configure the addon with a public key."
    exit 1
fi

# Write the public key to /.well-known/com.tesla.3p.public-key.pem
mkdir -p /data/.well-known
echo "$PUBLIC_KEY" > /data/.well-known/com.tesla.3p.public-key.pem

# Start a simple HTTP server to serve the public key
python3 -m http.server 8000