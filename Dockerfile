FROM alpine:latest
RUN apk add --no-cache wget ca-certificates
COPY sync.sh /sync.sh
RUN chmod +x /sync.sh
ENTRYPOINT ["/bin/sh", "/sync.sh"]
