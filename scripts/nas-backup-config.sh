#!/bin/bash
# Auto Config Backup Script
# Runs every Sunday at 3:00 AM via cron
# Backs up all important config files to your 4TB drive
# Keeps last 30 days of backups and deletes older ones automatically
#
# Setup:
# 1. sudo nano /usr/local/bin/nas-backup-config.sh  (paste this script)
# 2. sudo chmod +x /usr/local/bin/nas-backup-config.sh
# 3. sudo crontab -e  (add this line:)
#    0 3 * * 0 /usr/local/bin/nas-backup-config.sh
#
# Replace YOUR_NEXTCLOUD_ADMIN with your actual Nextcloud admin username

BACKUP_DIR="/mnt/drive4tb/nextcloud-data/YOUR_NEXTCLOUD_ADMIN/files/4TB/NAS-Config-Backups"
DATE=$(date +%Y-%m-%d)

mkdir -p "$BACKUP_DIR/$DATE"

cp /var/www/nextcloud/config/config.php "$BACKUP_DIR/$DATE/config.php"
cp /etc/samba/smb.conf "$BACKUP_DIR/$DATE/smb.conf"
cp /etc/fstab "$BACKUP_DIR/$DATE/fstab"
cp /etc/apt/apt.conf.d/50unattended-upgrades "$BACKUP_DIR/$DATE/50unattended-upgrades"

chown -R www-data:www-data "$BACKUP_DIR"

# Delete backups older than 30 days
find "$BACKUP_DIR" -mindepth 1 -maxdepth 1 -type d -mtime +30 -exec rm -rf {} +

echo "Config backup completed: $DATE"
