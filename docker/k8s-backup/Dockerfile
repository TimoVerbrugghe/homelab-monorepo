FROM alpine:latest

# Create appdata & backup folder
RUN mkdir -p /appdata /backup
VOLUME ["/appdata", "/backup"]

# Define required environment variables (to be set by the user at runtime)
ENV BACKUP_NAME=""

# Container start
ENTRYPOINT [ "/k8sbackup.sh" ]