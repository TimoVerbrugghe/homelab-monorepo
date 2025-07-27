FROM alpine:latest

# Create appdata & restore folder
RUN mkdir -p /appdata /restore
VOLUME ["/appdata", "/restore"]

# Container start
ENTRYPOINT [ "/k8srestore.sh" ]