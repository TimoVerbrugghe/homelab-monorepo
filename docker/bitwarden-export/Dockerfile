FROM alpine:latest

# Install prerequisites (npm & jq for json reading)
RUN apk add --update --no-cache npm jq bash
RUN npm install -g @bitwarden/cli

# Copy over custom scripts for crontab & export
COPY bitwardenexport.sh /
RUN chmod +x /bitwardenexport.sh

# Create appdata folder for backup & export
RUN mkdir -p /backup
VOLUME ["/backup"]

# Set environment variable for nodejs since bw cli still uses deprecated punycode npm module, this env variable suppresses these warnings.
ENV NODE_OPTIONS="--no-deprecation"

# Define required environment variables (to be set by the user at runtime)
ENV BW_CLIENTID=""
ENV BW_CLIENTSECRET=""
ENV BW_SERVER=""
ENV BW_PASSWORD=""
ENV BW_APPID=""

# Container start
ENTRYPOINT [ "/bitwardenexport.sh" ]
