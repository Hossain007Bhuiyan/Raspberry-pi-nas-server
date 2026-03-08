#!/bin/bash
# Drive SMART Health Check Script
# Runs every Sunday at 4:00 AM via cron
# Checks 4TB and 650GB HDD health and saves a report you can read anytime
#
# IMPORTANT: Requires smartmontools — install with: sudo apt install smartmontools -y
# IMPORTANT: Test first before enabling — run manually and check output:
#   sudo smartctl -H -d sat $(df /mnt/drive4tb | awk 'NR==2{print $1}' | sed 's/[0-9]*$//')
# If you see "PASSED" — this script will work on your setup.
# If you see an error — SMART is not supported through your dock. Skip this script.
#
# Setup:
# 1. sudo apt install smartmontools -y
# 2. sudo nano /usr/local/bin/nas-drive-health.sh  (paste this script)
# 3. sudo chmod +x /usr/local/bin/nas-drive-health.sh
# 4. sudo crontab -e  (add this line:)
#    0 4 * * 0 /usr/local/bin/nas-drive-health.sh
#
# Read the report anytime with: cat /home/YOUR_SSH_USERNAME/drive-health-report.txt

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

echo "Drive health report saved to $REPORT"
