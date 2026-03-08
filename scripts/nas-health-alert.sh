#!/bin/bash
# Health Monitoring and Email Alert Script
# Runs every 6 hours via cron
# Monitors your NAS and sends an email ONLY when a problem is detected
# No email = everything is running fine
#
# What it monitors:
# - Pi CPU temperature (alerts if above 75°C)
# - Both drives mounted (alerts if a drive is missing)
# - All services running: apache2, smbd, redis-server (alerts if any crashes)
# - 4TB drive usage (alerts if above 90% full)
# - Drive SMART health (alerts if drive is failing or has bad sectors)
#
# IMPORTANT: Requirements before using this script:
# 1. Gmail account with 2-Step Verification turned ON
# 2. Gmail App Password generated (see Part 14.7 of the guide for step-by-step instructions)
# 3. msmtp installed and configured (see Part 14.7 of the guide)
# 4. smartmontools installed: sudo apt install smartmontools -y
# 5. Test SMART works: sudo smartctl -H -d sat $(df /mnt/drive4tb | awk 'NR==2{print $1}' | sed 's/[0-9]*$//')
#    If you see an error instead of PASSED — remove the SMART check sections from this script
#
# Setup:
# 1. Complete the msmtp setup in Part 14.7 of the guide first
# 2. Replace YOUR_EMAIL@gmail.com with your actual Gmail address
# 3. sudo nano /usr/local/bin/nas-health-alert.sh  (paste this script)
# 4. sudo chmod +x /usr/local/bin/nas-health-alert.sh
# 5. sudo crontab -e  (add this line:)
#    0 */6 * * * /usr/local/bin/nas-health-alert.sh

EMAIL="YOUR_EMAIL@gmail.com"
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

# Send email only if there is a problem detected
if [ "$ALERT" -eq 1 ]; then
    { echo "To: $EMAIL"; echo "Subject: NAS Pi Alert!"; echo ""; echo -e "$MESSAGE"; } | msmtp "$EMAIL"
    echo "Alert email sent: $(date '+%Y-%m-%d %H:%M:%S')"
else
    echo "Health check passed — no issues detected: $(date '+%Y-%m-%d %H:%M:%S')"
fi
