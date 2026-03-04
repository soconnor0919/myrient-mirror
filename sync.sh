#!/bin/sh
BASE_URL="https://myrient.erista.me/files"

# List of systems to sync
SYSTEMS="No-Intro/Nintendo - Nintendo Entertainment System (Headerless)
No-Intro/Nintendo - Super Nintendo Entertainment System
No-Intro/Nintendo - Nintendo 64 (BigEndian)
No-Intro/Nintendo - Game Boy
No-Intro/Nintendo - Game Boy Color
No-Intro/Nintendo - Game Boy Advance
No-Intro/Nintendo - Nintendo DS (Decrypted)
Redump/Nintendo - GameCube - NKit RVZ [zstd-19-128k]
Redump/Nintendo - Wii - NKit RVZ [zstd-19-128k]"

echo "Starting Myrient Mirror Process..."

IFS='
'
for system in $SYSTEMS; do
    [ -z "$system" ] && continue
    echo "---------------------------------------------------"
    echo "Syncing: $system"
    echo "---------------------------------------------------"
    
    wget -m -np -c -R "index.html*" \
         --accept-regex ".*\(USA\).*" \
         "$BASE_URL/$system/" \
         -P /data/
done

echo "Mirroring Complete."
