#!/bin/sh

echo "Building queue..."
python3 /manager.py

echo "Starting Aria2 Engine with RPC..."
aria2c --enable-rpc=true --rpc-listen-all=true --rpc-allow-origin-all=true \
       --rpc-listen-port=6800 --dir=/data -j 5 -x 16 -s 16 \
       --auto-file-renaming=false --continue=true \
       -i /tmp/aria2.queue &

echo "Serving AriaNg Web UI on port 8267..."
# We serve from /ui
cd /ui && python3 -m http.server 8267
