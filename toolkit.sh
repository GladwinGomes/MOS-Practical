#!/bin/bash
# toolkit.sh - card-style menu launcher for the sysadmin toolkit
DIR="$(cd "$(dirname "$0")" && pwd)"

# ---------- colours ----------
RST=$'\e[0m'; BOLD=$'\e[1m'; DIM=$'\e[2m'
C1=$'\e[38;5;99m'     # indigo
C2=$'\e[38;5;71m'     # green
C3=$'\e[38;5;178m'    # amber
C4=$'\e[38;5;166m'    # red-orange
W=32                  # inner text width of a card

rep() { local s="" i; for ((i=0; i<$1; i++)); do s+="$2"; done; printf '%s' "$s"; }

# cell <card 1-4> <row 0-5> : prints one line of a card
cell() {
    local col t b1 b2 b3 b
    case $1 in
        1) col=$C1; t="1  File organizer";    b1="Sort by type";           b2="Sort by date";           b3="Never overwrites files" ;;
        2) col=$C2; t="2  Backup automation"; b1="Timestamped archives";  b2="Compress old backups";   b3="Activity log" ;;
        3) col=$C3; t="3  Log cleaner";       b1="Remove old entries";    b2="Error & warning report"; b3="Backup copy kept" ;;
        4) col=$C4; t="4  Health monitor";    b1="CPU, RAM, disk checks"; b2="Threshold warnings";     b3="Cron scheduling" ;;
    esac
    case $2 in
        0) printf '%s╭%s╮%s' "$col" "$(rep $((W+2)) '─')" "$RST" ;;
        1) printf '%s│ %s%-*s%s │%s' "$col" "$BOLD" "$W" "$t" "$RST$col" "$RST" ;;
        2|3|4)
            case $2 in 2) b=$b1 ;; 3) b=$b2 ;; 4) b=$b3 ;; esac
            printf '%s│%s • %-*s %s│%s' "$col" "$RST" $((W-2)) "$b" "$col" "$RST" ;;
        5) printf '%s╰%s╯%s' "$col" "$(rep $((W+2)) '─')" "$RST" ;;
    esac
}

draw_row() {
    local r
    for r in 0 1 2 3 4 5; do
        printf '  '; cell "$1" "$r"; printf '  '; cell "$2" "$r"; echo
    done
}

menu() {
    clear
    echo
    echo "  ${BOLD}Sysadmin toolkit${RST}"
    echo "  ${DIM}Four Bash tools for everyday Linux maintenance${RST}"
    echo
    draw_row 1 2
    echo
    draw_row 3 4
    echo
    echo "  ${DIM}5  Exit${RST}"
    echo
}

# ask <prompt> <default> : reads a value, applies the default, expands ~
ask() {
    local v
    read -rp "  $1 [$2]: " v
    v="${v:-$2}"
    printf '%s' "${v/#\~/$HOME}"
}

# run <script> [args...] : runs a script from the toolkit folder
run() {
    local s="$DIR/$1"; shift
    echo
    if [ -f "$s" ]; then bash "$s" "$@"; else echo "  Missing script: $s"; fi
}

pause() { echo; read -rp "  Press Enter to return to the menu..." _; }

while true; do
    menu
    read -rp "  Choose 1-5: " choice
    case $choice in
        1) f=$(ask "Folder to organize" "$HOME/messy"); m=$(ask "Mode (type/date)" "type")
           run file_organizer.sh "$f" "$m"; pause ;;
        2) s=$(ask "Folder to back up" "$HOME/important"); b=$(ask "Backup folder" "$HOME/backups")
           run backup_auto.sh "$s" "$b"; pause ;;
        3) l=$(ask "Log file" "$DIR/app.log"); d=$(ask "Days to keep" "7")
           run log_cleaner.sh -f "$l" -d "$d"; pause ;;
        4) run health_monitor.sh; pause ;;
        5) echo; echo "  Goodbye!"; exit 0 ;;
        *) echo; echo "  Please enter a number from 1 to 5."; pause ;;
    esac
done
