#!/bin/bash

LOG_FILE="/var/log/mikrotik.log"
FILTER="firewall|description|full_log|add|remove|change|drop|accept"
BACKUP_SCRIPT="/opt/mikrotik-firewall/mikrotik-firewall-monitor.sh"
LOCKFILE="/tmp/mikrotik_backup.lock"
MIN_INTERVAL=120  # sekundy (2 minuty)

tail -Fn0 "$LOG_FILE" | while read line; do
    echo "$line" | grep -Ei "$FILTER" > /dev/null
    if [ $? = 0 ]; then
        echo "[+] Wykryto ważny wpis MikroTik: $line"

        NOW=$(date +%s)
        if [ -f "$LOCKFILE" ]; then
            LAST_RUN=$(cat "$LOCKFILE")
        else
            LAST_RUN=0
        fi

        DIFF=$(( NOW - LAST_RUN ))

        if [ $DIFF -ge $MIN_INTERVAL ]; then
            echo $NOW > "$LOCKFILE"
            echo "[*] Uruchamiam backup"
            bash "$BACKUP_SCRIPT"
        else
            echo "[*] Backup był wykonywany niedawno, pomijam"
        fi
    fi
done
