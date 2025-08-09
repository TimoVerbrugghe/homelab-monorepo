FROM alpine:latest

# Create appdata & backup folder
RUN mkdir -p /appdata /backup
VOLUME ["/appdata", "/backup"]

COPY k8sbackup.sh /k8sbackup.sh
RUN chmod +x /k8sbackup.sh

# Define required environment variables (to be set by the user at runtime)
ENV BACKUP_NAME=""

# Container start
ENTRYPOINT [ "/k8sbackup.sh" ]