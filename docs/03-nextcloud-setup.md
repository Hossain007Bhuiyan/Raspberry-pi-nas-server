# Part 3 — Install Nextcloud (Your Personal Cloud)

> **INFO:** Nextcloud = your private Google Drive. Access files from any browser anywhere, auto photo backup from iPhone and Android, sync folders on MacBook and Windows.

---

## 3.1 — Install Apache web server

```bash
sudo apt update
sudo apt install apache2 -y
```

---

## 3.2 — Add PHP 8.3 repository and install PHP

```bash
sudo apt install -y lsb-release ca-certificates curl
curl -fsSL https://packages.sury.org/php/apt.gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/sury-php.gpg
echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/sury-php.list
sudo apt update
sudo apt install -y php8.3 libapache2-mod-php8.3 php8.3-gd php8.3-curl php8.3-zip php8.3-xml php8.3-mbstring php8.3-mysql php8.3-bz2 php8.3-intl php8.3-gmp php8.3-bcmath php8.3-imagick php8.3-opcache php8.3-apcu php8.3-redis php8.3-cli
```

---

## 3.3 — Install and secure MariaDB database

```bash
sudo apt install mariadb-server -y
sudo mysql_secure_installation
```

| Question asked | Your answer |
|---|---|
| Enter current password for root | Press Enter (no password yet) |
| Switch to unix_socket authentication? | `n` |
| Change the root password? | `y` then type: your chosen DB root password |
| Remove anonymous users? | `y` |
| Disallow root login remotely? | `y` |
| Remove test database? | `y` |
| Reload privilege tables? | `y` |

Create Nextcloud database and user:
```bash
sudo mysql -u root -p
```

Enter password: your DB root password. Then type each line one at a time:
```sql
CREATE DATABASE nextclouddb CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
CREATE USER 'YOUR_DB_USERNAME'@'localhost' IDENTIFIED BY 'YOUR_DB_PASSWORD';
GRANT ALL PRIVILEGES ON nextclouddb.* TO 'YOUR_DB_USERNAME'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

---

## 3.4 — Download and extract Nextcloud

```bash
cd /var/www/
sudo wget https://download.nextcloud.com/server/releases/latest.tar.bz2
sudo tar -xvf latest.tar.bz2
sudo rm latest.tar.bz2
```

Many filenames scroll past during extraction — this is normal.

---

## 3.5 — Create data folders on 4TB drive

```bash
sudo mkdir -p /mnt/drive4tb/nextcloud-data
sudo mkdir -p /mnt/drive4tb/shared-files
sudo chown -R www-data:www-data /mnt/drive4tb/nextcloud-data
sudo chown -R www-data:www-data /mnt/drive4tb/shared-files
sudo chmod 750 /mnt/drive4tb/nextcloud-data
sudo chmod 775 /mnt/drive4tb/shared-files
sudo chown -R www-data:www-data /var/www/nextcloud/
```

Verify folders are correct:
```bash
sudo ls -la /mnt/drive4tb/
```

You should see: `nextcloud-data` owned by `www-data` with `drwxr-x---` permissions
You should see: `shared-files` owned by `www-data` with `drwxrwxr-x` permissions

---

## 3.6 — Configure Apache to serve Nextcloud

```bash
sudo nano /etc/apache2/sites-available/nextcloud.conf
```

Paste this exactly:
```apache
Alias /nextcloud "/var/www/nextcloud/"

<Directory /var/www/nextcloud/>
    Require all granted
    AllowOverride All
    Options FollowSymLinks MultiViews

    <IfModule mod_dav.c>
        Dav off
    </IfModule>
</Directory>
```

Save: `Ctrl+X` → `Y` → `Enter`

```bash
sudo a2ensite nextcloud.conf
sudo a2enmod rewrite headers env dir mime
sudo systemctl reload apache2
```

---

## 3.7 — Tune PHP settings for better performance

```bash
sudo nano /etc/php/8.3/apache2/php.ini
```

Use `Ctrl+W` to search for each setting below. Change the value on that line.

> ⚠️ Many lines start with a semicolon `;` which means the setting is disabled. You must REMOVE the semicolon AND change the value.
> Example: `;opcache.enable=0` becomes `opcache.enable = 1`

| Search for this (Ctrl+W) | Change the line to this |
|---|---|
| `memory_limit` | `memory_limit = 512M` |
| `upload_max_filesize` | `upload_max_filesize = 2048M` |
| `post_max_size` | `post_max_size = 2048M` |
| `max_execution_time` | `max_execution_time = 360` |
| `max_input_time` | `max_input_time = 360` |
| `opcache.enable` | `opcache.enable = 1` |
| `opcache.interned_strings_buffer` | `opcache.interned_strings_buffer = 16` |
| `opcache.max_accelerated_files` | `opcache.max_accelerated_files = 10000` |
| `opcache.memory_consumption` | `opcache.memory_consumption = 128` |
| `opcache.save_comments` | `opcache.save_comments = 1` |
| `opcache.revalidate_freq` | `opcache.revalidate_freq = 1` |

Save: `Ctrl+X` → `Y` → `Enter`

```bash
sudo systemctl restart apache2
```

---

## 3.8 — Complete Nextcloud setup in browser

> ⚠️ **Use Safari, not Chrome.** Chrome has a known bug with local IP redirects during Nextcloud setup — it strips the IP and shows 'site cannot be reached'.

On MacBook open **Safari** and go to:
```
http://YOUR_LOCAL_IP/nextcloud
```

| Field in setup form | Value to enter |
|---|---|
| Administration account name | `YOUR_NEXTCLOUD_ADMIN` |
| Administration account password | `YOUR_NEXTCLOUD_PASSWORD` |
| Data folder | `/mnt/drive4tb/nextcloud-data` — **CHANGE THIS — default is wrong!** |
| Database type | Click **MySQL/MariaDB** — NOT SQLite |
| Database user | `YOUR_DB_USERNAME` |
| Database password | `YOUR_DB_PASSWORD` |
| Database name | `nextclouddb` |
| Database host | `localhost` |

> ⚠️ The Data folder defaults to `/var/www/nextcloud/data` which is on the microSD card. You MUST change it to `/mnt/drive4tb/nextcloud-data`. If you miss this, your files go to the tiny 128GB microSD instead of the 4TB HDD.

Click **Install**. Wait 3–5 minutes without clicking anything or refreshing.

When you see the Nextcloud dashboard, installation is complete:

![Nextcloud Dashboard — fully working in browser](../images/nextcloud-dashboard.png)

> If browser redirects to `nextcloud/index.php...` and shows error after install: Chrome strips the IP from the redirect URL. Open Safari and manually go to: `http://YOUR_LOCAL_IP/nextcloud`

---

## 3.9 — Fix 'Access through untrusted domain' error

This error appears when accessing via Tailscale IP or custom domain. Fix it by adding all your addresses to trusted_domains.

```bash
sudo nano /var/www/nextcloud/config/config.php
```

Use `Ctrl+W` to search for: `trusted_domains`

Change it to look exactly like this — replace all placeholders with your actual values:
```php
'trusted_domains' =>
array (
  0 => 'YOUR_LOCAL_IP',
  1 => 'YOUR_TAILSCALE_IP',
  2 => 'YOUR_HOSTNAME.local',
  3 => 'YOUR_HOSTNAME',
  4 => 'YOUR_TAILSCALE_MACHINE_FQDN',
  5 => 'YOUR_CUSTOM_DOMAIN',
),
```

> **What each entry covers:**
> - `0` — Local IP access at home
> - `1` — Tailscale IP access from anywhere
> - `2` — mDNS hostname on local network (e.g. `naspi.local`)
> - `3` — Plain hostname (e.g. `naspi`)
> - `4` — Full Tailscale machine name (e.g. `naspi.tail3195f2.ts.net`) — find yours at https://login.tailscale.com/admin/machines
> - `5` — Your custom domain (e.g. `hossain.nas`) — set up in Part 15

Save: `Ctrl+X` → `Y` → `Enter`

```bash
sudo systemctl restart apache2
```

---

## 3.10 — Install Redis cache (makes Nextcloud faster and fixes file uploads)

> Redis is required for file locking to work. Without the correct Redis config, ALL file uploads fail with 'Unknown error'.

```bash
sudo apt install redis-server php8.3-redis -y
sudo usermod -a -G redis www-data
sudo systemctl restart redis-server
sudo systemctl enable redis-server
```

Verify Redis is running:
```bash
sudo systemctl status redis-server
```

Look for: `active (running)` and `Ready to accept connections` and `redis-server 127.0.0.1:6379`

Add Redis config to Nextcloud:
```bash
sudo nano /var/www/nextcloud/config/config.php
```

Find the closing `);` at the very bottom. Add these lines BEFORE the `);`
```php
'memcache.local' => '\OC\Memcache\APCu',
'memcache.locking' => '\OC\Memcache\Redis',
'redis' => [
    'host' => '127.0.0.1',
    'port' => 6379,
],
```

> ⚠️ **CRITICAL:** The host must be `127.0.0.1` and port must be `6379`. Do NOT use `/var/run/redis/redis-server.sock` as the host — that socket file does not exist in this setup. Using the socket path causes RedisException errors on every single file upload.

Save: `Ctrl+X` → `Y` → `Enter`

```bash
sudo systemctl restart apache2
```

---

## 3.11 — Set up automatic background tasks

```bash
sudo crontab -u www-data -e
```

If asked which editor → type `1` → Enter (selects nano). Add these two lines at the bottom:
```
*/5 * * * * php -f /var/www/nextcloud/cron.php
*/5 * * * * php /var/www/nextcloud/occ files:scan --all -q
```

Save: `Ctrl+X` → `Y` → `Enter`

- **Line 1:** Runs Nextcloud internal background tasks every 5 minutes.
- **Line 2:** Automatically rescans your files folder every 5 minutes. Files added via Samba appear in Nextcloud within 5 minutes automatically — no manual command needed ever.

Set background jobs to Cron in Nextcloud web interface:
- Open `http://YOUR_LOCAL_IP/nextcloud` in Safari
- Click user icon (top right) → Administration Settings
- Scroll left menu → Basic settings → Background jobs → select **Cron**

Both drives are now visible in Nextcloud:

![Nextcloud Files — both 4TB and 650GB drives visible as folders](../images/nextcloud-files-both-drives.png)

Activity log tracking all changes automatically:

![Nextcloud Activity Log — showing automatic file tracking](../images/nextcloud-activity-log.png)

---

## 3.14 — Speed Optimizations for Nextcloud

> Run these steps after Nextcloud is fully installed and working. They make Nextcloud significantly faster for all devices — especially photo browsing and global access.

**Step 1 — Enable HTTP/2:**
```bash
sudo a2enmod http2
sudo systemctl restart apache2
```

**Step 2 — Fix database and run maintenance:**
```bash
sudo -u www-data php /var/www/nextcloud/occ db:add-missing-indices
sudo -u www-data php /var/www/nextcloud/occ db:add-missing-primary-keys
sudo -u www-data php /var/www/nextcloud/occ maintenance:repair
```

**Step 3 — Install and run preview generator:**
```bash
sudo -u www-data php /var/www/nextcloud/occ app:install previewgenerator
```

Run once to generate all existing file previews. This runs in the background — takes several hours depending on how many files you have:
```bash
sudo nohup sudo -u www-data php /var/www/nextcloud/occ preview:generate-all \
  > /home/YOUR_SSH_USERNAME/preview.log 2>&1 &
```

Check progress anytime:
```bash
tail -f /home/YOUR_SSH_USERNAME/preview.log
```

Check if finished:
```bash
ps aux | grep preview
```

If only the `grep` line shows — finished. ✅

**Step 4 — Add preview cron so new files get previews automatically:**
```bash
sudo crontab -u www-data -e
```

Add this line at the bottom:
```
*/30 * * * * php /var/www/nextcloud/occ preview:generate-all
```

Save: `Ctrl+X` → `Y` → `Enter`

✅ After these steps Nextcloud photo folders and thumbnails load significantly faster from all devices.

---

[← HDD Setup](02-hdd-setup.md) | [Back to README](../README.md) | [Next: Tailscale VPN →](04-tailscale-vpn.md)
