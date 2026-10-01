#!/bin/bash
# log_cleaner.sh - removes old log entries and prints an error/warning report
# Expects log lines starting with: YYYY-MM-DD HH:MM:SS LEVEL message
# Usage: ./log_cleaner.sh -f <logfile> [-d days]

DAYS=7
LOGFILE=""

usage() {
    echo "Usage: $0 -f <logfile> [-d days_to_keep]"
    exit 1
}

while getopts "f:d:h" opt; do
    case $opt in
        f) LOGFILE="$OPTARG" ;;
        d) DAYS="$OPTARG" ;;
        *) usage ;;
    esac
done

[ -z "$LOGFILE" ] && usage
[ -f "$LOGFILE" ] || { echo "File not found: $LOGFILE"; exit 1; }

CUTOFF=$(date -d "$DAYS days ago" +%Y-%m-%d)
TMP=$(mktemp)
BEFORE=$(wc -l < "$LOGFILE")

# keep only lines whose date >= cutoff (ISO dates compare correctly as strings)
awk -v cutoff="$CUTOFF" '$1 >= cutoff' "$LOGFILE" > "$TMP"
cp "$LOGFILE" "$LOGFILE.bak"     # safety copy
mv "$TMP" "$LOGFILE"

AFTER=$(wc -l < "$LOGFILE")

echo "=========== LOG REPORT ==========="
echo "File          : $LOGFILE"
echo "Keep since    : $CUTOFF (last $DAYS days)"
echo "Lines before  : $BEFORE"
echo "Lines after   : $AFTER"
echo "Removed       : $((BEFORE - AFTER))"
echo "----------------------------------"
echo "Errors        : $(grep -c ' ERROR ' "$LOGFILE")"
echo "Warnings      : $(grep -c ' WARN' "$LOGFILE")"
echo "----------------------------------"
echo "Top recurring errors/warnings:"
grep -E ' (ERROR|WARN)' "$LOGFILE" \
    | awk '{ $1=""; $2=""; print }' \
    | sort | uniq -c | sort -rn | head -5
echo "=================================="
echo "Backup of original saved as $LOGFILE.bak"
