FROM alpine:latest

# Create appdata & backup folder
RUN mkdir -p /appdata /backup
VOLUME ["/appdata", "/backup"]

COPY k8srestore.sh /k8srestore.sh
RUN chmod +x /k8srestore.sh

# Container start
ENTRYPOINT [ "/k8srestore.sh" ]