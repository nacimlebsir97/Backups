#!/bin/bash

# === Configuration ===
SOURCE="/home/user/data"
DEST="/mnt/backup/data"
LOGFILE="/var/log/backup.log"
DATE=$(date "+%Y-%m-%d %H:%M:%S")

# === Run rsync ===
echo "[$DATE] Starting backup..." >> "$LOGFILE"
rsync -avh --delete "$SOURCE/" "$DEST/" >> "$LOGFILE" 2>&1

# === Log completion ===
if [ $? -eq 0 ]; then
    echo "[$DATE] Backup completed successfully." >> "$LOGFILE"
else
    echo "[$DATE] Backup failed." >> "$LOGFILE"
fi

