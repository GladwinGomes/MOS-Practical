#!/bin/bash
# ================================================
#  health_monitor.sh - CPU / RAM / Disk watchdog
#  Run manually or via cron
# ================================================

# ---------- CONFIG ----------
CPU_LIMIT=80
RAM_LIMIT=80
DISK_LIMIT=85
LOG_FILE="$HOME/health_monitor.log"
# ----------------------------

TIME=$(date '+%Y-%m-%d %H:%M:%S')

# CPU: sample /proc/stat twice, one second apart
read -r _ u1 n1 s1 i1 w1 q1 sq1 _ < /proc/stat
sleep 1
read -r _ u2 n2 s2 i2 w2 q2 sq2 _ < /proc/stat
idle1=$((i1 + w1));   idle2=$((i2 + w2))
total1=$((u1 + n1 + s1 + i1 + w1 + q1 + sq1))
total2=$((u2 + n2 + s2 + i2 + w2 + q2 + sq2))
CPU=$(( 100 * ( (total2 - total1) - (idle2 - idle1) ) / (total2 - total1) ))

# RAM %
RAM=$(free | awk '/Mem:/ {printf "%d", $3/$2 * 100}')

# Disk % of root partition
DISK=$(df / | awk 'NR==2 {gsub("%",""); print $5}')

STATUS="OK"
ALERTS=""

check() {   # name value limit
    if [ "$2" -ge "$3" ]; then
        STATUS="WARNING"
        ALERTS="$ALERTS [$1 at $2% >= $3%]"
    fi
}

check "CPU"  "$CPU"  "$CPU_LIMIT"
check "RAM"  "$RAM"  "$RAM_LIMIT"
check "DISK" "$DISK" "$DISK_LIMIT"

LINE="$TIME | CPU: ${CPU}% | RAM: ${RAM}% | DISK: ${DISK}% | $STATUS$ALERTS"
echo "$LINE"
echo "$LINE" >> "$LOG_FILE"

[ "$STATUS" = "WARNING" ] && echo "*** ALERT: resource usage critical! ***"
