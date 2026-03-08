#!/bin/bash
# Nextcloud Database Optimization Script
# Runs every Sunday at 6:00 AM via cron
# Keeps your Nextcloud database fast and clean as more files are added over time
#
# Setup:
# 1. Replace YOUR_DB_ROOT_PASSWORD with your actual MariaDB root password
# 2. sudo nano /usr/local/bin/nas-db-optimize.sh  (paste this script)
# 3. sudo chmod +x /usr/local/bin/nas-db-optimize.sh
# 4. sudo crontab -e  (add this line:)
#    0 6 * * 0 /usr/local/bin/nas-db-optimize.sh
#
# Test manually first: sudo /usr/local/bin/nas-db-optimize.sh
# No errors = working correctly

sudo -u www-data php /var/www/nextcloud/occ db:add-missing-indices --no-interaction
sudo -u www-data php /var/www/nextcloud/occ db:add-missing-primary-keys --no-interaction
MYSQL_PWD='YOUR_DB_ROOT_PASSWORD' mysqlcheck -u root --optimize nextclouddb --silent

echo "Database optimization completed: $(date '+%Y-%m-%d %H:%M:%S')"
