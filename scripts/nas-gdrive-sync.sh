#!/bin/bash
# Auto Google Drive Sync Script
# Runs every night at 2:00 AM via cron
# Checks Google Drive for new files and copies them to your 4TB drive
# Only copies NEW files — never deletes anything from your NAS
#
# IMPORTANT: You must complete Part 13 of the guide first to set up rclone and
# authorize Google Drive. This script will not work without that step.
#
# Setup:
# 1. Complete Part 13 of the setup guide first (rclone Google Drive authorization)
# 2. Edit this script — add your Google Drive folder names in the rclone copy lines
# 3. Replace YOUR_NEXTCLOUD_ADMIN and YOUR_SSH_USERNAME with your actual values
# 4. sudo nano /usr/local/bin/nas-gdrive-sync.sh  (paste this script)
# 5. sudo chmod +x /usr/local/bin/nas-gdrive-sync.sh
# 6. sudo crontab -e  (add this line:)
#    0 2 * * * /usr/local/bin/nas-gdrive-sync.sh
#
# Check sync log anytime: tail -20 /home/YOUR_SSH_USERNAME/gdrive-auto-sync.log

LOG="/home/YOUR_SSH_USERNAME/gdrive-auto-sync.log"
DATE=$(date '+%Y-%m-%d %H:%M:%S')

# Keep only last 500 lines to prevent log growing too large
[ -f "$LOG" ] && tail -500 "$LOG" > "$LOG.tmp" && mv "$LOG.tmp" "$LOG"

echo "============================" >> "$LOG"
echo "Auto sync started: $DATE" >> "$LOG"

# Add your Google Drive folders here — one rclone copy line per folder
# Replace YOUR_GDRIVE_FOLDER_NAME with your actual Google Drive folder name
rclone copy "googledrive:YOUR_GDRIVE_FOLDER_NAME" \
  /mnt/drive4tb/nextcloud-data/YOUR_NEXTCLOUD_ADMIN/files/4TB/GoogleDrive/YOUR_GDRIVE_FOLDER_NAME/ \
  --transfers=2 --checkers=4 --drive-chunk-size=32M -v >> "$LOG" 2>&1

# To sync additional folders, add another rclone copy line here following the same format

chown -R www-data:www-data /mnt/drive4tb/nextcloud-data/YOUR_NEXTCLOUD_ADMIN/files/4TB/GoogleDrive/

echo "Sync finished: $(date '+%Y-%m-%d %H:%M:%S')" >> "$LOG"

# Scan new files into Nextcloud so they appear in the web interface
sudo -u www-data php /var/www/nextcloud/occ files:scan --all -q
