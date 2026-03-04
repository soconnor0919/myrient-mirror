#!/bin/sh

# Default Configuration
SYNC_SYSTEMS="${SYNC_SYSTEMS:-NES,SNES,N64,GB,GBC,GBA,DS,GC,WII}"
REGION_FILTER="${REGION_FILTER:-.*\(USA\).*}"
WGET_TIMEOUT="${WGET_TIMEOUT:-30}"
WGET_RETRIES="${WGET_RETRIES:-20}"
LOG_FILE="/data/mirror.log"

BASE_URL="https://myrient.erista.me/files"

# Map shortcuts to full Myrient paths
get_path() {
    case "$1" in
        NES)  echo "No-Intro/Nintendo - Nintendo Entertainment System (Headerless)" ;;
        SNES) echo "No-Intro/Nintendo - Super Nintendo Entertainment System" ;;
        N64)  echo "No-Intro/Nintendo - Nintendo 64 (BigEndian)" ;;
        GB)   echo "No-Intro/Nintendo - Game Boy" ;;
        GBC)  echo "No-Intro/Nintendo - Game Boy Color" ;;
        GBA)  echo "No-Intro/Nintendo - Game Boy Advance" ;;
        DS)   echo "No-Intro/Nintendo - Nintendo DS (Decrypted)" ;;
        GC)   echo "Redump/Nintendo - GameCube - NKit RVZ [zstd-19-128k]" ;;
        WII)  echo "Redump/Nintendo - Wii - NKit RVZ [zstd-19-128k]" ;;
        *)    echo "$1" ;; 
    esac
}

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "Starting Enhanced Myrient Mirror..."
log "Target Systems: $SYNC_SYSTEMS"
log "Region Filter: $REGION_FILTER"

# Split by comma
OLD_IFS=$IFS
IFS=','
for sys in $SYNC_SYSTEMS; do
    path=$(get_path "$sys")
    log "---------------------------------------------------"
    log "Processing: $sys ($path)"
    log "---------------------------------------------------"

    wget -m -np -c -R "index.html*" \
         --accept-regex "$REGION_FILTER" \
         --tries="$WGET_RETRIES" \
         --timeout="$WGET_TIMEOUT" \
         --waitretry=5 \
         --retry-connrefused \
         "$BASE_URL/$path/" \
         -P /data/ 2>&1 | tee -a "$LOG_FILE"

    if [ $? -eq 0 ]; then
        log "Finished syncing $sys"
    else
        log "Warning: wget exited with non-zero status for $sys. Check log for details."
    fi
done
IFS=$OLD_IFS

log "Full Mirroring Process Complete."
