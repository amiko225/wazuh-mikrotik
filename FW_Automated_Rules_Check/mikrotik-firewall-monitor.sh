#!/bin/bash

MT_IP="192.168.80.1"
MT_USER="admin"
SSH_OPTIONS="-i /home/wazuhadmin/.ssh/id_ed25519 -o StrictHostKeyChecking=no"
EXPORT_CMD="/ip firewall export terse"

DIR="/opt/mikrotik-firewall"
FILE="$DIR/firewall_export.rsc"

cd "$DIR" || exit 1

ssh $SSH_OPTIONS "${MT_USER}@${MT_IP}" "$EXPORT_CMD" > "$FILE.new"


if ! diff -q "$FILE" "$FILE.new" > /dev/null 2>&1; then
    mv "$FILE.new" "$FILE"
    git pull origin master || echo "Git pull error: $? at $(date)" >> error.log
    git add firewall_export.rsc
    git commit -m "Zmiana reguł FW: $(date '+%Y-%m-%d %H:%M:%S')"
    git push origin master
    echo "[+] Backup wykonany i wypchnięty do GitHub"
else
    rm "$FILE.new"
    echo "[-] Brak zmian w konfiguracji"
fi