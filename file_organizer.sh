#!/bin/bash
# file_organizer.sh - sorts files in a folder by type or by date
# Usage: ./file_organizer.sh [folder] [type|date]

FOLDER="${1:-$HOME/Downloads}"
MODE="${2:-type}"

if [ ! -d "$FOLDER" ]; then
    echo "Error: $FOLDER does not exist"
    exit 1
fi

echo "Organizing $FOLDER by $MODE ..."
count=0

for file in "$FOLDER"/*; do
    # skip folders
    [ -f "$file" ] || continue

    name=$(basename "$file")

    if [ "$MODE" = "date" ]; then
        # folder named like 2026-10
        target=$(date -r "$file" +%Y-%m)
    else
        ext="${name##*.}"
        ext=$(echo "$ext" | tr 'A-Z' 'a-z')
        case "$ext" in
            jpg|jpeg|png|gif|bmp|webp)  target="Images" ;;
            pdf|doc|docx|txt|odt|pptx)  target="Documents" ;;
            mp3|wav|flac|aac)           target="Audio" ;;
            mp4|mkv|avi|mov)            target="Videos" ;;
            zip|tar|gz|rar|7z)          target="Archives" ;;
            sh|py|c|cpp|java|js)        target="Code" ;;
            *)                          target="Others" ;;
        esac
    fi

    mkdir -p "$FOLDER/$target"
    mv -n "$file" "$FOLDER/$target/"     # -n = never overwrite
    echo "Moved: $name -> $target/"
    count=$((count + 1))
done

echo "Done. $count file(s) organized."
