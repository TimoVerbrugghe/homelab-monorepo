FROM alpine:latest

# Install prerequisites (npm & jq for json reading)
RUN apk add --update --no-cache npm jq bash
RUN npm install -g @bitwarden/cli

# Copy over custom scripts for crontab & export
COPY bitwardenexport.sh entry.sh /
RUN chmod +x /bitwardenexport.sh /entry.sh

# Create appdata folder for backup & export
RUN mkdir -p /appdata
VOLUME ["/appdata"]

# Set environment variable for nodejs since bw cli still uses deprecated punycode npm module, this env variable suppresses these warnings.
ENV NODE_OPTIONS="--no-deprecation"


# Container start
ENTRYPOINT [ "/entry.sh" ]
