- Rsync is a powerful and flexible command-line tool used to synchronize files and directories between local and remote systems. For users who prefer a graphical interface, tools like Nextcloud provide a Dropbox- or Google Drive-like experience. However, command-line users will find rsync sufficient and efficient for file transfers.
- It simplifies file transfers and allows developers to build and maintain websites offline, then push updates directly to a server without needing to stay logged in.

# Main interesting modes of transfers

## Partial transfers

- When an rsync transfer is interrupted, it can leave a partial file on the destination.
- With --partial, Rsync keeps this incomplete file instead of deleting it.
- With `--partial-dir=.rsync-partial`, it saves the partial file in a special directory, allowing resuming later without re-transferring the whole file.

## Delta transfers

- Rsync uses a delta-transfer algorithm.
- It compares the source and destination files and only transfers the differences (deltas), not the entire file.
- This makes updates to large files much faster and efficient, especially over networks.

---

# Getting Started with Rsync

## Copy files with Rsync

1. Basic copy: `rsync file /path/to/destination`
2. With Options: `rsync -av --progress -h file /path/to/dest` 
    - `-a` = Archive Mode, Enables a group of options that preserve the structure and metadata of files. Equivalent to `-rlptgoD`:
        - `-r` - recursive (copies directories)
        - `-l` - copies symlinks as symlinks
        - `-p` - preserves permissions
        - `-t` - preserves modification times
        - `-g` - preserves group ownership
        - `-o` - preserves file ownership
        - `-D` - preserves device and special files (if run as root)
	- `-v` = Verbose. 
        - Outputs progress and information during transfer.
        - Useful for logging and understanding what's happening during the backup.
	- `--progress` =  Show percentage progress of the copy.
	- `-h` = Human readable.
        - Formats file sizes in a more readable way (e.g., 1.2K, 2.1M).
        - Especially useful when -v is enabled.

## Move files with rsync

- We add `--remove-source-files` to copy mode flags: `rsync -av --progress -h --remove-source-files  file /path/to/dest`
- The source file will not be deleted unless the transfer completes successfully, making it safe even in case of connection loss or power failure.

## Rsync on the network

- Be cautious when using the `-a` (archive) flag for uploading to a remote server, as it preserves user and group ownership from the local system, which may conflict with server permissions or break file access.
- From your local machine you can upload files to your server like this: `rsync -rtvzP /path/to/file root@example.org:/path/on/the/server`
- This command uses several options to customize rsync’s behavior. You can add or remove flags based on your specific needs:
	- `-r` – run recurssively (include directories)
	- `-t` – transfer modification times, which allows skipping files that have not been modified on future uploads
	- `-v` – visual, show files uploaded
	- `-z` – compress files for upload
	- `-P` – If an upload is interrupted, rsync can resume where it left off instead of restarting the entire transfer.

## Additional Useful Options

1. `--dry-run` is used to perform a trial run of the synchronization without actually making any changes to the destination. It allows you to see what actions Rsync would take based on your command and options, but it doesn't modify any files.
2. Exclude any hidden files: `rsync -av --exclude '.' /path/to/src /path/to/dest`

---

# Rsync for backups with cron

1. Basic Rsync Backup Script with Logging

```
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
```

2. Make it executable: `chmod +x /usr/local/bin/backup.sh`

3. `--delete` flag Explanation, Dangerous if misused, but useful:
    - Deletes files in the destination ($DEST) that no longer exist in the source ($SOURCE).
    - Keeps destination in exact sync with source (a mirror).
    - Prevents accumulation of outdated/deleted files in backups.


4. Cron Job to Schedule Daily Backups
- To schedule this backup to run every day at 2:00 AM: `crontab -e`
```
0 2 * * * /usr/local/bin/backup.sh

```
