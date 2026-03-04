#!/bin/sh
export RCLONE_CONFIG_MYRIENT_TYPE=http
export RCLONE_CONFIG_MYRIENT_URL=https://myrient.erista.me/files/

SYSTEMS="No-Intro/Nintendo - Nintendo Entertainment System
No-Intro/Nintendo - Super Nintendo Entertainment System
No-Intro/Nintendo - Nintendo 64
No-Intro/Nintendo - Game Boy
No-Intro/Nintendo - Game Boy Color
No-Intro/Nintendo - Game Boy Advance
No-Intro/Nintendo - Nintendo DS (Decrypted)
Redump/Nintendo - GameCube - NKit RVZ [zstd-19-128k]
Redump/Nintendo - Wii - NKit RVZ [zstd-19-128k]"

echo "Starting Myrient Mirror Process..."

echo "$SYSTEMS" | while read -r system; do
    [ -z "$system" ] && continue
    echo "---------------------------------------------------"
    echo "Syncing: $system"
    echo "---------------------------------------------------"
    rclone copy "myrient:$system" "/data/$system" \
        --include "*(USA)*" \
        --multi-thread-streams 0 \
        --transfers 1 \
        --checkers 1 \
        --stats 10s \
        -vP
done

echo "Mirroring Complete."
