#!/bin/bash
# toolkit.sh - menu launcher for the 4 scripts
DIR="$(cd "$(dirname "$0")" && pwd)"

while true; do
    echo
    echo "======== SYSADMIN TOOLKIT ========"
    echo "1) Bulk File Organizer"
    echo "2) Backup Automation"
    echo "3) Log Cleaner & Report"
    echo "4) System Health Monitor"
    echo "5) Exit"
    echo "=================================="
    read -rp "Choose an option: " choice

    case $choice in
        1)
            read -rp "Folder to organize: " f
            read -rp "Mode (type/date): " m
            "$DIR/file_organizer.sh" "$f" "$m"
            ;;
        2)
            read -rp "Source folder: " s
            read -rp "Backup folder: " b
            "$DIR/backup_auto.sh" "$s" "$b"
            ;;
        3)
            read -rp "Log file: " l
            read -rp "Days to keep: " d
            "$DIR/log_cleaner.sh" -f "$l" -d "$d"
            ;;
        4)
            "$DIR/health_monitor.sh"
            ;;
        5)
            echo "Goodbye!"; exit 0
            ;;
        *)
            echo "Invalid option"
            ;;
    esac
done
