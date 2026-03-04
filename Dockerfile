FROM rclone/rclone:latest
COPY sync.sh /sync.sh
RUN chmod +x /sync.sh
ENTRYPOINT ["/bin/sh", "/sync.sh"]
