FROM alpine:latest
RUN apk add --no-cache aria2 python3 py3-requests ca-certificates
COPY manager.py /manager.py
COPY sync.sh /sync.sh
RUN chmod +x /sync.sh
ADD https://github.com/mayswind/AriaNg/releases/download/1.3.7/AriaNg-1.3.7.zip /ui.zip
RUN unzip /ui.zip -d /ui && rm /ui.zip
EXPOSE 8267 6800
ENTRYPOINT ["/bin/sh", "/sync.sh"]
