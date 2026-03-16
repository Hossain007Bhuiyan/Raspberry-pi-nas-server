# Part 14 — Automation

This section sets up 7 automatic tasks that keep your NAS healthy, safe and up to date — all running silently in the background without any manual action needed.

| Time | What runs |
|---|---|
| Every 5 minutes | Nextcloud file scan (already set up in Part 3.11) |
| 2:00 AM daily | Google Drive auto sync |
| 3:00 AM every Sunday | Config backup |
| 4:00 AM every Sunday | Drive health check |
| 5:00 AM every Sunday | Log cleanup |
| 6:00 AM every Sunday | Database optimization |
| Every 6 hours | Health alert email (only sent if a problem is detected) |

---

## 14.1 — Auto Config Backup (Every Sunday 3:00 AM)

Automatically backs up your most important config files to the 4TB drive every week. If anything breaks you can restore instantly. Keeps last 30 days of backups and deletes older ones automatically.

Create the backup script:
```bash
sudo nano /usr/local/bin/nas-backup-config.sh
```

Paste this exactly — replace `YOUR_NEXTCLOUD_ADMIN` with your actual Nextcloud admin username:
```bash
#!/bin/bash
BACKUP_DIR="/mnt/drive4tb/nextcloud-data/YOUR_NEXTCLOUD_ADMIN/files/4TB/NAS-Config-Backups"
DATE=$(date +%Y-%m-%d)
mkdir -p "$BACKUP_DIR/$DATE"
cp /var/www/nextcloud/config/config.php "$BACKUP_DIR/$DATE/config.php"
cp /etc/samba/smb.conf "$BACKUP_DIR/$DATE/smb.conf"
cp /etc/fstab "$BACKUP_DIR/$DATE/fstab"
cp /etc/apt/apt.conf.d/50unattended-upgrades "$BACKUP_DIR/$DATE/50unattended-upgrades"
chown -R www-data:www-data "$BACKUP_DIR"
find "$BACKUP_DIR" -mindepth 1 -maxdepth 1 -type d -mtime +30 -exec rm -rf {} +
```

Save: `Ctrl+X` → `Y` → `Enter`

Make it executable:
```bash
sudo chmod +x /usr/local/bin/nas-backup-config.sh
```

Add to cron:
```bash
sudo crontab -e
```

Add this line at the bottom:
```
0 3 * * 0 /usr/local/bin/nas-backup-config.sh
```

Save: `Ctrl+X` → `Y` → `Enter`

Verify it works manually:
```bash
sudo /usr/local/bin/nas-backup-config.sh
ls /mnt/drive4tb/nextcloud-data/YOUR_NEXTCLOUD_ADMIN/files/4TB/NAS-Config-Backups/
```

✅ You should see a dated folder — backup is working correctly.

---

## 14.2 — Auto Drive Health Check (Every Sunday 4:00 AM)

Checks your 4TB and 650GB HDD health every week and saves a report you can read anytime. Detects drive problems before they cause data loss.

Install smartmontools:
```bash
sudo apt install smartmontools -y
```

Test it works first:
```bash
sudo smartctl -H -d sat $(df /mnt/drive4tb | awk 'NR==2{print $1}' | sed 's/[0-9]*$//')
sudo smartctl -H -d sat $(df /mnt/650GB | awk 'NR==2{print $1}' | sed 's/[0-9]*$//')
```

You should see: `SMART overall-health self-assessment test result: PASSED` for both drives.

> ⚠️ The `-d sat` flag is required because your drives connect via USB through the RSHTECH dock. Without it smartctl cannot read the drive health data.
>
> SMART health reading through USB dock is not guaranteed on all RSHTECH models. You must run the test command first. If it returns PASSED — everything works. If it returns an error — SMART is not supported through your dock and sections 14.2 and the SMART parts of 14.7 should be skipped.

Create the health check script:
```bash
sudo nano /usr/local/bin/nas-drive-health.sh
```

Paste this exactly — replace `YOUR_SSH_USERNAME` with your actual SSH username:
```bash
#!/bin/bash
REPORT="/home/YOUR_SSH_USERNAME/drive-health-report.txt"
DATE=$(date '+%Y-%m-%d %H:%M:%S')
DRIVE4TB=$(df /mnt/drive4tb | awk 'NR==2{print $1}' | sed 's/[0-9]*$//')
DRIVE650=$(df /mnt/650GB | awk 'NR==2{print $1}' | sed 's/[0-9]*$//')
echo "============================" > "$REPORT"
echo "Drive Health Report: $DATE" >> "$REPORT"
echo "============================" >> "$REPORT"
echo "" >> "$REPORT"
echo "--- 4TB Drive ---" >> "$REPORT"
smartctl -H -d sat "$DRIVE4TB" >> "$REPORT"
echo "" >> "$REPORT"
echo "--- 650GB Drive ---" >> "$REPORT"
smartctl -H -d sat "$DRIVE650" >> "$REPORT"
echo "" >> "$REPORT"
echo "--- Disk Usage ---" >> "$REPORT"
df -h | grep /mnt >> "$REPORT"
echo "============================" >> "$REPORT"
```

Save: `Ctrl+X` → `Y` → `Enter`

Make it executable:
```bash
sudo chmod +x /usr/local/bin/nas-drive-health.sh
```

Add to cron:
```bash
sudo crontab -e
```

Add this line at the bottom:
```
0 4 * * 0 /usr/local/bin/nas-drive-health.sh
```

Save: `Ctrl+X` → `Y` → `Enter`

Check the report anytime:
```bash
cat /home/YOUR_SSH_USERNAME/drive-health-report.txt
```

✅ Drive health uses mount points to find drives — works correctly even if device names change after reboot.

---

## 14.3 — Auto Log Cleanup (Every Sunday 5:00 AM)

Prevents system logs from filling up your 128GB microSD card over time. Automatically deletes all logs older than 30 days every Sunday.

Add to cron:
```bash
sudo crontab -e
```

Add this line at the bottom:
```
0 5 * * 0 journalctl --vacuum-time=30d > /dev/null 2>&1
```

Save: `Ctrl+X` → `Y` → `Enter`

Check current log size anytime:
```bash
journalctl --disk-usage
```

✅ This keeps your microSD card healthy long term.

---

## 14.4 — Auto Nextcloud Database Optimization (Every Sunday 6:00 AM)

Keeps your Nextcloud database fast and clean as more files are added over time.

Create the optimization script:
```bash
sudo nano /usr/local/bin/nas-db-optimize.sh
```

Paste this exactly — replace `YOUR_DB_ROOT_PASSWORD` with your actual MariaDB root password:
```bash
#!/bin/bash
sudo -u www-data php /var/www/nextcloud/occ db:add-missing-indices --no-interaction
sudo -u www-data php /var/www/nextcloud/occ db:add-missing-primary-keys --no-interaction
MYSQL_PWD='YOUR_DB_ROOT_PASSWORD' mysqlcheck -u root --optimize nextclouddb --silent
```

Save: `Ctrl+X` → `Y` → `Enter`

Make it executable:
```bash
sudo chmod +x /usr/local/bin/nas-db-optimize.sh
```

Add to cron:
```bash
sudo crontab -e
```

Add this line at the bottom:
```
0 6 * * 0 /usr/local/bin/nas-db-optimize.sh
```

Save: `Ctrl+X` → `Y` → `Enter`

Run manually first to verify it works:
```bash
sudo /usr/local/bin/nas-db-optimize.sh
```

✅ No errors = working correctly.

---

## 14.5 — Auto Nextcloud File Scan

Already set up in Part 3.11 — runs every 5 minutes automatically. Nothing to do. ✅

---

## 14.6 — Auto Google Drive Sync (Every Night 2:00 AM)

Automatically checks Google Drive for new files every night and copies them to your 4TB drive. Only copies NEW files — never deletes anything from your NAS.

Create the sync script:
```bash
sudo nano /usr/local/bin/nas-gdrive-sync.sh
```

Paste this exactly — replace `YOUR_NEXTCLOUD_ADMIN`, `YOUR_SSH_USERNAME`, and `YOUR_GDRIVE_FOLDER_NAME` with your actual values:
```bash
#!/bin/bash
LOG="/home/YOUR_SSH_USERNAME/gdrive-auto-sync.log"
DATE=$(date '+%Y-%m-%d %H:%M:%S')

# Keep only last 500 lines to prevent log growing too large
[ -f "$LOG" ] && tail -500 "$LOG" > "$LOG.tmp" && mv "$LOG.tmp" "$LOG"

echo "============================" >> "$LOG"
echo "Auto sync started: $DATE" >> "$LOG"

rclone copy "googledrive:YOUR_GDRIVE_FOLDER_NAME" \
  /mnt/drive4tb/nextcloud-data/YOUR_NEXTCLOUD_ADMIN/files/4TB/GoogleDrive/YOUR_GDRIVE_FOLDER_NAME/ \
  --transfers=2 --checkers=4 --drive-chunk-size=32M -v >> "$LOG" 2>&1

chown -R www-data:www-data \
  /mnt/drive4tb/nextcloud-data/YOUR_NEXTCLOUD_ADMIN/files/4TB/GoogleDrive/

echo "Sync finished: $(date '+%Y-%m-%d %H:%M:%S')" >> "$LOG"
sudo -u www-data php /var/www/nextcloud/occ files:scan --all -q
```

Save: `Ctrl+X` → `Y` → `Enter`

> ⚠️ If you want to sync more Google Drive folders — add another `rclone copy` line inside the script for each folder using the same format as the line above.

Make it executable:
```bash
sudo chmod +x /usr/local/bin/nas-gdrive-sync.sh
```

Add to cron:
```bash
sudo crontab -e
```

Add this line at the bottom:
```
0 2 * * * /usr/local/bin/nas-gdrive-sync.sh
```

Save: `Ctrl+X` → `Y` → `Enter`

Check sync log anytime:
```bash
tail -20 /home/YOUR_SSH_USERNAME/gdrive-auto-sync.log
```

✅ Sync runs silently every night. You only need to check the log if something seems wrong.

---

## 14.7 — Auto Email Health Alert (Every 6 Hours)

Monitors your NAS every 6 hours and sends you an email alert ONLY when a problem is detected. No email = everything is fine. You will be alerted if temperature is too high, a drive is not mounted, a service has crashed, or 4TB drive is more than 90% full.

> ⚠️ **Requirements:** Gmail account with 2-Step Verification turned ON. You need to generate a Gmail App Password before starting.

**Step 1 — Generate Gmail App Password:**
- Go to `myaccount.google.com` on MacBook
- Click Security → 2-Step Verification → scroll down → App passwords
- Select app: Mail → Select device: Other → type: `NAS Pi` → Generate
- Copy the 16-character password shown — you need this in Step 3

**Step 2 — Install required packages:**
```bash
sudo apt install msmtp msmtp-mta bc -y
```

**Step 3 — Configure msmtp:**
```bash
sudo nano /etc/msmtprc
```

Paste this exactly — replace `your.email@gmail.com` and `your-app-password` with your real values:
```
defaults
auth           on
tls            on
tls_trust_file /etc/ssl/certs/ca-certificates.crt
logfile        /var/log/msmtp.log

account        gmail
host           smtp.gmail.com
port           587
from           your.email@gmail.com
user           your.email@gmail.com
password       your-app-password

account default : gmail
```

Save: `Ctrl+X` → `Y` → `Enter`

Set correct permissions:
```bash
sudo chmod 600 /etc/msmtprc
```

**Step 4 — Test email works:**
```bash
echo "Test email from NAS Pi" | sudo msmtp your.email@gmail.com
```

Check your Gmail inbox — you should receive the test email. ✅

If no email arrives — check the log:
```bash
sudo cat /var/log/msmtp.log
```

**Step 5 — Create health alert script:**
```bash
sudo nano /usr/local/bin/nas-health-alert.sh
```

Paste this exactly — replace `your.email@gmail.com` with your real Gmail address:
```bash
#!/bin/bash
EMAIL="your.email@gmail.com"
ALERT=0
MESSAGE="NAS Pi Health Report - $(date '+%Y-%m-%d %H:%M:%S')\n\n"

# Check temperature
TEMP=$(vcgencmd measure_temp | grep -o '[0-9]*\.[0-9]*')
MESSAGE+="Temperature: ${TEMP}°C\n"
if (( $(echo "$TEMP > 75" | bc -l) )); then
    ALERT=1
    MESSAGE+="WARNING: Temperature too high!\n"
fi

# Check drives mounted
if ! df -h | grep -q /mnt/drive4tb; then
    ALERT=1
    MESSAGE+="WARNING: 4TB drive not mounted!\n"
fi
if ! df -h | grep -q /mnt/650GB; then
    ALERT=1
    MESSAGE+="WARNING: 650GB drive not mounted!\n"
fi

# Check services
for SERVICE in apache2 smbd redis-server; do
    if ! systemctl is-active --quiet "$SERVICE"; then
        ALERT=1
        MESSAGE+="WARNING: $SERVICE is not running!\n"
    fi
done

# Check disk usage
USAGE=$(df /mnt/drive4tb | awk 'NR==2{print $5}' | tr -d '%')
MESSAGE+="4TB drive usage: ${USAGE}%\n"
if [ "$USAGE" -gt 90 ]; then
    ALERT=1
    MESSAGE+="WARNING: 4TB drive almost full!\n"
fi

# Check drive SMART health
DRIVE4TB=$(df /mnt/drive4tb | awk 'NR==2{print $1}' | sed 's/[0-9]*$//')
DRIVE650=$(df /mnt/650GB | awk 'NR==2{print $1}' | sed 's/[0-9]*$//')

if smartctl -H -d sat "$DRIVE4TB" 2>/dev/null | grep -q "FAILED"; then
    ALERT=1
    MESSAGE+="WARNING: 4TB drive SMART FAILED — replace immediately!\n"
fi

BAD4TB=$(smartctl -A -d sat "$DRIVE4TB" 2>/dev/null | awk \
  '/Reallocated_Sector_Ct|Current_Pending_Sector|Offline_Uncorrectable/ {if ($10+0 > 0) print $2": "$10}')
if [ -n "$BAD4TB" ]; then
    ALERT=1
    MESSAGE+="WARNING: 4TB drive bad sectors detected: $BAD4TB\n"
fi

if smartctl -H -d sat "$DRIVE650" 2>/dev/null | grep -q "FAILED"; then
    ALERT=1
    MESSAGE+="WARNING: 650GB drive SMART FAILED — replace immediately!\n"
fi

BAD650=$(smartctl -A -d sat "$DRIVE650" 2>/dev/null | awk \
  '/Reallocated_Sector_Ct|Current_Pending_Sector|Offline_Uncorrectable/ {if ($10+0 > 0) print $2": "$10}')
if [ -n "$BAD650" ]; then
    ALERT=1
    MESSAGE+="WARNING: 650GB drive bad sectors detected: $BAD650\n"
fi

# Send email only if there is a problem
if [ "$ALERT" -eq 1 ]; then
    { echo "To: $EMAIL"; echo "Subject: NAS Pi Alert!"; echo ""; echo -e "$MESSAGE"; } | msmtp "$EMAIL"
fi
```

Save: `Ctrl+X` → `Y` → `Enter`

Make it executable:
```bash
sudo chmod +x /usr/local/bin/nas-health-alert.sh
```

Add to cron — runs every 6 hours:
```bash
sudo crontab -e
```

Add this line at the bottom:
```
0 */6 * * * /usr/local/bin/nas-health-alert.sh
```

Save: `Ctrl+X` → `Y` → `Enter`

✅ You only receive an email when there is a problem. No email = everything is running fine.

---

## 14.8 — Verify All Automation is Set Up Correctly

The automation cron jobs are split across two separate crontabs. Check both to confirm everything is set up correctly.

**Check root automation cron jobs:**
```bash
sudo crontab -l
```

You should see these 6 lines:
```
0 2 * * * /usr/local/bin/nas-gdrive-sync.sh
0 3 * * 0 /usr/local/bin/nas-backup-config.sh
0 4 * * 0 /usr/local/bin/nas-drive-health.sh
0 5 * * 0 journalctl --vacuum-time=30d > /dev/null 2>&1
0 6 * * 0 /usr/local/bin/nas-db-optimize.sh
0 */6 * * * /usr/local/bin/nas-health-alert.sh
```

**Check Nextcloud file scan and preview cron (runs separately as www-data):**
```bash
sudo crontab -u www-data -l
```

You should see these 3 lines:
```
*/5 * * * * php -f /var/www/nextcloud/cron.php
*/5 * * * * php /var/www/nextcloud/occ files:scan --all -q
*/30 * * * * php /var/www/nextcloud/occ preview:generate-all
```

> The third line (`preview:generate-all`) is added in Part 3 Step 14. If you have not completed that step yet, you will only see 2 lines — that is also fine.

✅ All 7 automations confirmed running. Your NAS is now fully automated.

---

[← Google Drive Sync](13-google-drive-sync.md) | [Back to README](../README.md)
