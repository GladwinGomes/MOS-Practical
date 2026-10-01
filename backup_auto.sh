#!/usr/bin/env bash
# backup_auto.sh - timestamped backups with compression, rotation and logging
# Usage: ./backup_auto.sh <source_dir> <backup_dir>

set -euo pipefail

SOURCE_DIR="${1:?Usage: $0 <source_dir> <backup_dir>}"
BACKUP_DIR="${2:?Usage: $0 <source_dir> <backup_dir>}"
COMPRESS_AFTER_DAYS=1     # gzip plain .tar backups older than this
DELETE_AFTER_DAYS=7       # remove compressed backups older than this
LOG_FILE="$BACKUP_DIR/backup.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

validate() {
    [[ -d "$SOURCE_DIR" ]] || { echo "Source not found: $SOURCE_DIR"; exit 1; }
    mkdir -p "$BACKUP_DIR"
}

create_backup() {
    local stamp archive
    stamp=$(date +%Y%m%d_%H%M%S)
    archive="$BACKUP_DIR/backup_${stamp}.tar"
    tar -cf "$archive" -C "$(dirname "$SOURCE_DIR")" "$(basename "$SOURCE_DIR")"
    log "Created backup: $(basename "$archive") ($(du -h "$archive" | cut -f1))"
}

compress_old() {
    local n=0
    while IFS= read -r -d '' f; do
        gzip "$f" && log "Compressed: $(basename "$f")"
        n=$((n + 1))
    done < <(find "$BACKUP_DIR" -name "*.tar" -mtime +"$COMPRESS_AFTER_DAYS" -print0)
    log "Compressed $n old backup(s)"
}

delete_expired() {
    local n
    n=$(find "$BACKUP_DIR" -name "*.tar.gz" -mtime +"$DELETE_AFTER_DAYS" -print -delete | wc -l)
    log "Deleted $n expired backup(s)"
}

main() {
    validate
    log "=== Backup started: $SOURCE_DIR ==="
    create_backup
    compress_old
    delete_expired
    log "=== Backup finished ==="
}

main
