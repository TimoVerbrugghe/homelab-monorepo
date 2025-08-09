FROM alpine:latest

# Create appdata & restore folder
RUN mkdir -p /appdata /restore
VOLUME ["/appdata", "/restore"]

COPY k8srestore.sh /k8srestore.sh
RUN chmod +x /k8srestore.sh

# Container start
ENTRYPOINT [ "/k8srestore.sh" ]