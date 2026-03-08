# 🖥️ Raspberry Pi 4 — NAS Storage Server

![Raspberry Pi](https://img.shields.io/badge/Raspberry%20Pi-4-red?logo=raspberry-pi)
![OS](https://img.shields.io/badge/OS-Raspberry%20Pi%20OS%20Lite%2064--bit-green)
![Nextcloud](https://img.shields.io/badge/Nextcloud-Latest-blue?logo=nextcloud)
![Samba](https://img.shields.io/badge/Samba-File%20Sharing-orange)
![Tailscale](https://img.shields.io/badge/Tailscale-VPN-purple)
![Status](https://img.shields.io/badge/Status-Fully%20Working-brightgreen)

A complete, fully working **self-hosted NAS (Network Attached Storage) server** built on Raspberry Pi 4.
Runs **Nextcloud + Samba + Tailscale VPN** — WiFi only, headless setup with no monitor or keyboard required.
All real-world errors encountered and solved. Fully tested and working.

> **Your private Google Drive — accessible from anywhere in the world, secured by VPN.**

---

## 📋 Table of Contents

- [Your Setup Reference](#your-setup-reference)
- [Hardware Used](#hardware-used)
- [Software Stack](#software-stack)
- [Network Architecture](#network-architecture)
- [Features](#features)
- [Part 0 — SSH Access](#part-0--ssh-access-how-to-control-your-pi-from-any-device)
- [Part 1 — Install Raspberry Pi OS](#part-1--install-raspberry-pi-os-wifi-only-headless-setup)
- [Part 2 — Connect HDDs and Mount Drives](#part-2--connect-hdds-and-mount-drives)
- [Part 3 — Install Nextcloud](#part-3--install-nextcloud-your-personal-cloud)
- [Part 4 — Install Tailscale VPN](#part-4--install-tailscale-vpn-secure-global-access)
- [Part 5 — Install Samba](#part-5--install-samba-fast-file-sharing--all-devices)
- [Part 6 — Accessing Files from All Devices](#part-6--accessing-files-from-all-devices)
- [Part 7 — Transferring Files to Your NAS](#part-7--transferring-files-to-your-nas)
- [Part 8 — Security Setup](#part-8--security-setup)
- [Part 9 — Troubleshooting Common Issues](#part-9--troubleshooting-common-issues)
- [Part 10 — Quick Reference Card](#part-10--complete-quick-reference-card)
- [Part 11 — Shutdown, Restart and Daily Use](#part-11--shutdown-restart-and-daily-use)- [Part 12 — Troubleshooting Unexpected Shutdowns](#part-12--troubleshooting-unexpected-shutdowns)
- [Part 13 — Transfer Files from Google Drive](#part-13--transfer-files-from-google-drive-to-nextcloud)
- [Part 3.14 — Speed Optimizations for Nextcloud](#part-314--speed-optimizations-for-nextcloud)
- [Part 14 — Automation](#part-14--automation)
- [Part 15 — Custom Domain](#part-15--custom-domain-your_hostnameNas)
- [Skills Demonstrated](#skills-demonstrated)

---

## Your Setup Reference

> ⚠️ **Fill in your own values below. Never share this table publicly with real passwords.**

| Your Setup Info | Value |
|---|---|
| Pi Local IP Address | `YOUR_LOCAL_IP` — find in your router admin page |
| Pi Tailscale IP (global) | `YOUR_TAILSCALE_IP` — shown after running `tailscale ip -4` |
| Pi Hostname | `naspi` / `naspi.local` |
| SSH Username | `YOUR_SSH_USERNAME` |
| SSH Password | `YOUR_SSH_PASSWORD` |
| Samba Username | `YOUR_SAMBA_USERNAME` |
| Samba Password | `YOUR_SAMBA_PASSWORD` |
| Nextcloud Admin Username | `YOUR_NEXTCLOUD_ADMIN` |
| Nextcloud Admin Password | `YOUR_NEXTCLOUD_PASSWORD` |
| MariaDB Root Password | `YOUR_DB_ROOT_PASSWORD` |
| Nextcloud DB Username | `YOUR_DB_USERNAME` |
| Nextcloud DB Password | `YOUR_DB_PASSWORD` |
| Nextcloud DB Name | `nextclouddb` |
| 4TB Drive Mount Point | `/mnt/drive4tb` |
| 650GB Drive Mount Point | `/mnt/650GB` |
| Nextcloud Data Folder | `/mnt/drive4tb/nextcloud-data` |
| 4TB Files Location | `/mnt/drive4tb/nextcloud-data/YOUR_NEXTCLOUD_ADMIN/files/4TB` |
| 650GB Files Location | `/mnt/drive4tb/nextcloud-data/YOUR_NEXTCLOUD_ADMIN/files/650GB` |

---

## Hardware Used

| Component | Specification |
|---|---|
| **Single Board Computer** | Raspberry Pi 4 Model B |
| **OS Storage** | 128GB microSD card |
| **Primary HDD** | 4TB Seagate IronWolf 3.5" NAS HDD |
| **Secondary HDD** | 650GB 2.5" Laptop HDD |
| **HDD Dock** | RSHTECH USB 3.0 HDD Docking Station |
| **Power Supply** | Official Raspberry Pi USB-C 5.1V 3A |
| **Network** | WiFi only — no Ethernet required |

![Hardware — RSHTECH Docking Station with Seagate IronWolf 4TB HDD](images/hardware-hdd-dock.jpg)

> The RSHTECH USB 3.0 docking station holds the 4TB Seagate IronWolf (right) and the 650GB laptop HDD (left). Both connect to the Pi via a single USB 3.0 cable.

---

## Software Stack

| Software | Purpose |
|---|---|
| Raspberry Pi OS Lite 64-bit (Bookworm) | Operating system |
| Nextcloud | Personal cloud — private Google Drive alternative |
| Apache2 | Web server for Nextcloud |
| PHP 8.3 | Runtime for Nextcloud |
| MariaDB | Database for Nextcloud |
| Redis | Cache and file locking |
| Samba | SMB file sharing for MacBook, iPhone, Windows, Android |
| Tailscale | Zero-config VPN for secure global access |
| UFW | Firewall |
| rclone | Google Drive to NAS sync tool |
| smartmontools | HDD health monitoring (SMART) |
| unattended-upgrades | Automatic security updates |

---

## Network Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        HOME NETWORK                          │
│                                                              │
│  ┌──────────┐    WiFi      ┌──────────────────────────────┐  │
│  │  Router  │◄────────────►│      Raspberry Pi 4          │  │
│  └──────────┘             │   IP: YOUR_LOCAL_IP           │  │
│                           │   Hostname: naspi             │  │
│                           │                              │  │
│                           │  ┌──────────┐  ┌──────────┐  │  │
│                           │  │  4TB HDD │  │ 650GB HDD│  │  │
│                           │  │/mnt/drive│  │/mnt/650GB│  │  │
│                           │  │  4tb     │  │          │  │  │
│                           │  └──────────┘  └──────────┘  │  │
│                           └──────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                                    │
                          Tailscale VPN Tunnel
                         (WireGuard encrypted)
                                    │
           ┌────────────────────────┼────────────────────┐
           │                        │                    │
    ┌──────▼──────┐        ┌────────▼──────┐   ┌────────▼─────┐
    │   MacBook   │        │    iPhone     │   │  Windows PC  │
    │  (anywhere) │        │  (anywhere)   │   │  (anywhere)  │
    └─────────────┘        └───────────────┘   └──────────────┘

Global Tailscale IP: YOUR_TAILSCALE_IP (permanent — never changes)
```

---

## Features

- ✅ Private cloud storage — access files from any browser anywhere
- ✅ Global VPN access via Tailscale — no port forwarding needed on router
- ✅ All devices supported — MacBook, iPhone, Android, Windows
- ✅ Auto photo backup — iPhone and Android photos sync automatically to NAS
- ✅ Samba file sharing — drives appear as normal network folders on all devices
- ✅ Same files, two protocols — Nextcloud and Samba access identical files, zero duplication
- ✅ Auto Google Drive sync — nightly sync from Google Drive to NAS
- ✅ Automatic file scanning — files added via Samba appear in Nextcloud within 5 minutes
- ✅ Weekly config backup — all config files backed up automatically every Sunday
- ✅ SMART drive health monitoring — weekly health report saved automatically
- ✅ Email health alerts — email sent only when a problem is detected, no false alarms
- ✅ Auto service crash recovery — Nextcloud, Samba, Redis restart within 10 seconds if they crash
- ✅ Firewall protection — UFW configured with minimal open ports
- ✅ Redis file locking — prevents file corruption during simultaneous access
- ✅ Static IP via DHCP reservation — Pi IP never changes after reboot
- ✅ nofail drive mounts — Pi boots safely even if a drive is disconnected

---

## Part 0 — SSH Access: How to Control Your Pi from Any Device

SSH is how you type commands on the Pi from another device. This is your only way to manage the Pi since it has no monitor or keyboard. You need this for all setup and maintenance.

### 0.1 — Connect from MacBook (Terminal)

Open Terminal: Applications → Utilities → Terminal

**When on HOME WiFi:**
```bash
ssh YOUR_SSH_USERNAME@YOUR_LOCAL_IP
```

**When OUTSIDE HOME (Tailscale must be ON on MacBook):**
```bash
ssh YOUR_SSH_USERNAME@YOUR_TAILSCALE_IP
```

First time only: type `yes` when asked about fingerprint → then enter your SSH password.

You are now inside your Pi when you see:
```
YOUR_SSH_USERNAME@naspi:~ $
```

### 0.2 — Connect from iPhone

Install **Termius** from App Store (free by Termius).

**Home WiFi setup:**
- Open Termius → tap `+` (top right) → New Host
- Label: `NAS Pi Home`
- Hostname: `YOUR_LOCAL_IP`
- Username: `YOUR_SSH_USERNAME`
- Password: `YOUR_SSH_PASSWORD`
- Tap Save → tap the host to connect
- First time only: tap Continue when asked about fingerprint

**Global access (from anywhere):**
- Make sure Tailscale is ON on iPhone first
- Create another host with Hostname: `YOUR_TAILSCALE_IP`
- Label: `NAS Pi Global`

### 0.3 — Connect from Android

Install **JuiceSSH** from Play Store (free by Sonelli).

- Open JuiceSSH → Connections tab → tap `+` (bottom right)
- Nickname: `NAS Pi Home` → Type: SSH → Address: `YOUR_LOCAL_IP`
- Tap identity field → New Identity → enter your username and password → Save
- Tap Save → tap connection to connect
- First time: tap Accept when asked about fingerprint

For global access: create same connection with Address: `YOUR_TAILSCALE_IP`

### 0.4 — Connect from Windows

Windows 10 and 11 have SSH built in — no extra app needed.

Open PowerShell (press Windows key → search PowerShell → open it):
```powershell
ssh YOUR_SSH_USERNAME@YOUR_LOCAL_IP
```

For global access (Tailscale must be ON in system tray):
```powershell
ssh YOUR_SSH_USERNAME@YOUR_TAILSCALE_IP
```

### 0.5 — Check if Pi is online before connecting

```bash
ping naspi.local
```

If you see replies — Pi is online. Press `Ctrl+C` to stop.
If ping fails: open router admin page → Connected Devices → find naspi → use that IP.

### 0.6 — Essential Commands Inside the Pi

| Command | What it does |
|---|---|
| `df -h \| grep /mnt` | Check how full your HDDs are |
| `lsblk` | See all connected drives and partitions |
| `sudo systemctl status apache2` | Check if Nextcloud is running |
| `sudo systemctl status smbd` | Check if Samba is running |
| `sudo systemctl status redis-server` | Check if Redis cache is running |
| `tailscale status` | Check Tailscale VPN and connected devices |
| `tailscale ip -4` | Show Pi's Tailscale IP |
| `sudo systemctl restart apache2` | Restart Nextcloud web server |
| `sudo systemctl restart smbd` | Restart Samba |
| `sudo apt update && sudo apt upgrade -y` | Update all software — do this monthly |
| `sudo reboot` | Restart Pi safely |
| `sudo shutdown -h now` | Shut Pi down safely |
| `exit` | Leave the SSH session |

---

## Part 1 — Install Raspberry Pi OS (WiFi-Only Headless Setup)

> **INFO:** Headless setup means no monitor, no keyboard, no Ethernet. Everything is configured inside Raspberry Pi Imager on your MacBook or Windows PC BEFORE the first boot.

### 1.1 — Download and open Raspberry Pi Imager

**On MacBook:**
- Go to: https://www.raspberrypi.com/software/
- Click Download for macOS → open `.dmg` → drag Raspberry Pi Imager to Applications → open it

**On Windows:**
- Go to: https://www.raspberrypi.com/software/
- Click Download for Windows → open the `.exe` installer → click Install → open Raspberry Pi Imager

### 1.2 — Configure ALL settings before writing

- Choose Device: **Raspberry Pi 4**
- Choose OS: **Raspberry Pi OS (other) → Raspberry Pi OS Lite (64-bit)** — Bookworm version
- Choose Storage: select your microSD card
- Click Next → click **Edit Settings** — fill in every single field:

| Setting | Value to enter |
|---|---|
| Hostname | `naspi` |
| Username | `YOUR_SSH_USERNAME` |
| Password | `YOUR_SSH_PASSWORD` |
| Configure WiFi | YES — enter your WiFi name exactly (it is case-sensitive) |
| WiFi Password | Your exact router WiFi password |
| WiFi Country | Your country code — e.g. `SE` for Sweden — **CRITICAL** |
| Enable SSH | YES — Use password authentication |
| Raspberry Pi Connect | OFF |
| Timezone | Your timezone — e.g. `Europe/Stockholm` |
| Keyboard | Your keyboard layout |

> ⚠️ **WiFi Country is absolutely critical.** Without it the Pi's WiFi hardware is disabled by law. You will have no connection at all and cannot connect remotely.

Click Save → Yes → confirm erase → Yes.
Wait 5–15 minutes. Do NOT remove the card until Imager says **Write Successful**.

**Eject microSD on MacBook:** Finder → right-click card → Eject
**Eject microSD on Windows:** System tray (bottom right) → Safely Remove Hardware → Eject → then remove

### 1.3 — First Boot

- Insert microSD into Pi — underside slot, gold contacts face the board, it clicks into place
- Do NOT connect HDDs yet
- Connect USB-C power cable — red LED solid, green LED flashing = Pi is booting
- Wait **2 full minutes** for first boot to complete

### 1.4 — Find Pi's IP address

**Method 1 — ping (MacBook Terminal or Windows PowerShell):**
```bash
ping naspi.local
```
The number in brackets is the IP address. Example: `PING naspi.local (192.168.X.XX)`

**Method 2 — router admin page (works from any device):**
Open `192.168.X.1` in browser → Connected Devices or DHCP Clients → find `naspi`

### 1.5 — SSH into Pi for the first time

```bash
ssh YOUR_SSH_USERNAME@YOUR_LOCAL_IP
```
Type `yes` → enter your SSH password.
You are in when you see: `YOUR_SSH_USERNAME@naspi:~ $`

### 1.6 — Set static IP (DHCP reservation in router)

- Log into router admin page
- Find **DHCP Reservation** or **Address Reservation** setting
- Find `naspi` → Reserve this IP → Save

✅ Pi's IP is now permanent. It will never change after reboots.

### 1.7 — Update system

```bash
sudo apt update
sudo apt upgrade -y
sudo reboot
```

Wait 1 minute after reboot, then SSH back in.

---

## Part 2 — Connect HDDs and Mount Drives

### 2.1 — Connect docking station

![RSHTECH USB 3.0 Docking Station with Seagate IronWolf 4TB HDD and 650GB laptop HDD](images/hardware-hdd-dock.jpg)

- Insert 4TB HDD (3.5 inch) into Bay A of the dock
- Insert 650GB HDD (2.5 inch) into Bay B of the dock
- Connect the 12V power adapter to dock and wall socket
- Connect USB 3.0 cable from dock to a **blue USB 3.0 port** on the Pi (blue = USB 3.0 = faster)
- Turn on the power switch on the back of the dock — drive lights should turn on

> ⚠️ Connect dock power FIRST, then the USB cable to Pi. Never connect or disconnect HDDs while the Pi is running — always shut down first.

### 2.2 — Format 650GB drive to ext4 (one time only)

> ⚠️ This erases ALL data on the 650GB drive. Make sure anything important is already backed up first.

```bash
sudo fdisk /dev/sdb
```

Inside fdisk — type each of these letters one at a time and press Enter after each:
```
d    ← delete partition (repeat until all partitions are deleted)
n    ← create new partition
p    ← primary partition
1    ← partition number 1
     ← press Enter (accept default first sector)
     ← press Enter (accept default last sector — uses full disk)
w    ← write changes and exit
```

Now format the new partition as ext4:
```bash
sudo mkfs.ext4 -L 650GB /dev/sdb1
```

Wait 1–2 minutes. You will see `done` on each line when finished.

### 2.3 — Verify both drives are detected

```bash
lsblk
```

| What you see | What it is |
|---|---|
| `sda` (3.6T) with `sda1` | Your 4TB HDD — ext4 format |
| `sdb` (596G) with `sdb1` | Your 650GB HDD — ext4 format |
| `mmcblk0` (119G) | Your microSD card — **NEVER touch this** |

### 2.4 — Find UUIDs of both drives

```bash
sudo blkid
```

> ⚠️ Always use UUID in fstab, never device names like `/dev/sda`. Device names can swap after reboot but UUIDs never change.

Write down your UUIDs from the output:
- **4TB drive UUID:** `YOUR_4TB_UUID`
- **650GB drive UUID:** `YOUR_650GB_UUID`

### 2.5 — Create mount point folders

```bash
sudo mkdir -p /mnt/drive4tb
sudo mkdir -p /mnt/650GB
```

These are the folders where your drives will appear in the Linux file system.

### 2.6 — Configure auto-mount (fstab)

Always back up fstab before editing — this is your safety net:
```bash
sudo cp /etc/fstab /etc/fstab.backup
```

Open fstab for editing:
```bash
sudo nano /etc/fstab
```

Add these three lines at the **VERY BOTTOM** of the file.
Replace the UUIDs with your actual UUIDs from Step 2.4:
```
UUID=YOUR_4TB_UUID /mnt/drive4tb ext4 defaults,auto,nofail,noatime 0 2
UUID=YOUR_650GB_UUID /mnt/650GB ext4 defaults,nofail 0 2
/mnt/650GB /mnt/drive4tb/nextcloud-data/YOUR_NEXTCLOUD_ADMIN/files/650GB none bind 0 0
```

| fstab Option | Why it matters |
|---|---|
| `nofail` | **CRITICAL:** Pi still boots if a drive is disconnected. Without this, a missing drive = Pi refuses to boot = you are locked out remotely forever |
| `noatime` | Does not update last-accessed timestamp — reduces unnecessary writes and extends drive life |
| `0 2` | Check drive integrity at boot, after the root filesystem is checked |
| `bind` | Makes the 650GB drive appear as a folder inside Nextcloud |

Save the file: press `Ctrl+X` → press `Y` → press `Enter`

Test that both drives mount correctly without rebooting:
```bash
sudo mount -a
df -h | grep /mnt
```

Both drives should now appear. This is what you should see:

![Terminal showing lsblk and df -h with both drives mounted correctly](images/terminal-drives-mounted.png)

> The top part shows `lsblk` — both `sda1` (4TB) and `sdb1` (650GB) are present with their mount points.
> The bottom part shows `df -h` — 4TB at `/mnt/drive4tb` and 650GB at `/mnt/650GB` both mounted and ready.

Now set correct ownership so Nextcloud can access the 650GB drive:
```bash
sudo chown -R www-data:www-data /mnt/650GB
sudo chmod -R 755 /mnt/650GB
sudo mkdir -p /mnt/drive4tb/nextcloud-data/YOUR_NEXTCLOUD_ADMIN/files/650GB
sudo chown www-data:www-data /mnt/drive4tb/nextcloud-data/YOUR_NEXTCLOUD_ADMIN/files/650GB
sudo systemctl daemon-reload
sudo mount -a
```

✅ The 650GB drive is now visible inside Nextcloud as a folder called `650GB` — same as the 4TB drive.

---

## Part 3 — Install Nextcloud (Your Personal Cloud)

> **INFO:** Nextcloud is your private Google Drive. Access files from any browser anywhere, auto photo backup from iPhone and Android, sync folders on MacBook and Windows.

### 3.1 — Install Apache web server

Apache is the web server that runs Nextcloud and makes it accessible in your browser.

```bash
sudo apt update
sudo apt install apache2 -y
```

### 3.2 — Add PHP 8.3 repository and install PHP

PHP is the programming language that Nextcloud is written in. We need version 8.3 for best performance.

```bash
sudo apt install -y lsb-release ca-certificates curl
curl -fsSL https://packages.sury.org/php/apt.gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/sury-php.gpg
echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/sury-php.list
sudo apt update
sudo apt install -y php8.3 libapache2-mod-php8.3 php8.3-gd php8.3-curl php8.3-zip php8.3-xml php8.3-mbstring php8.3-mysql php8.3-bz2 php8.3-intl php8.3-gmp php8.3-bcmath php8.3-imagick php8.3-opcache php8.3-apcu php8.3-redis php8.3-cli
```

### 3.3 — Install and secure MariaDB database

MariaDB is the database that stores all of Nextcloud's information about your files and users.

```bash
sudo apt install mariadb-server -y
sudo mysql_secure_installation
```

Answer each question exactly as follows:

| Question asked | Your answer |
|---|---|
| Enter current password for root | Press Enter — no password yet |
| Switch to unix_socket authentication? | Type `n` → Enter |
| Change the root password? | Type `y` → Enter → type your chosen DB root password |
| Remove anonymous users? | Type `y` → Enter |
| Disallow root login remotely? | Type `y` → Enter |
| Remove test database? | Type `y` → Enter |
| Reload privilege tables? | Type `y` → Enter |

Now create the Nextcloud database and database user:
```bash
sudo mysql -u root -p
```

Enter your DB root password when asked. Then type each line below one at a time, pressing Enter after each:
```sql
CREATE DATABASE nextclouddb CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
CREATE USER 'YOUR_DB_USERNAME'@'localhost' IDENTIFIED BY 'YOUR_DB_PASSWORD';
GRANT ALL PRIVILEGES ON nextclouddb.* TO 'YOUR_DB_USERNAME'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

### 3.4 — Download and extract Nextcloud

```bash
cd /var/www/
sudo wget https://download.nextcloud.com/server/releases/latest.tar.bz2
sudo tar -xvf latest.tar.bz2
sudo rm latest.tar.bz2
```

Many filenames scroll past during extraction — this is completely normal.

### 3.5 — Create data folders on 4TB drive

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

### 3.6 — Configure Apache to serve Nextcloud

```bash
sudo nano /etc/apache2/sites-available/nextcloud.conf
```

Paste this exactly as shown:
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

### 3.7 — Tune PHP settings for better performance

```bash
sudo nano /etc/php/8.3/apache2/php.ini
```

Use `Ctrl+W` to search for each setting below. Find the line and change the value.

> ⚠️ Important: Many lines start with a semicolon `;` which means that setting is disabled (commented out). You must REMOVE the semicolon AND change the value.
> Example: `;opcache.enable=0` must become `opcache.enable = 1`

| Search for this (Ctrl+W) | Change the entire line to this |
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

### 3.8 — Complete Nextcloud setup in browser

> ⚠️ **Use Safari, not Chrome.** Chrome has a known bug with local IP redirects during Nextcloud setup — it strips the IP from the URL and shows "site cannot be reached".

Open Safari on your MacBook and go to:
```
http://YOUR_LOCAL_IP/nextcloud
```

You will see a setup form. Fill in every field:

| Field in setup form | Value to enter |
|---|---|
| Administration account name | `YOUR_NEXTCLOUD_ADMIN` |
| Administration account password | `YOUR_NEXTCLOUD_PASSWORD` |
| Data folder | `/mnt/drive4tb/nextcloud-data` — **you must change this manually** |
| Database type | Click **MySQL/MariaDB** — NOT SQLite |
| Database user | `YOUR_DB_USERNAME` |
| Database password | `YOUR_DB_PASSWORD` |
| Database name | `nextclouddb` |
| Database host | `localhost` |

> ⚠️ The Data folder defaults to `/var/www/nextcloud/data` which is on the small microSD card. You MUST change it to `/mnt/drive4tb/nextcloud-data`. If you miss this step, all your files go to the tiny microSD card instead of your 4TB HDD.

Click **Install**. Wait 3–5 minutes without clicking anything or refreshing the page.

When you see the Nextcloud dashboard, the installation is complete:

![Nextcloud Dashboard — fully working and accessible in browser](images/nextcloud-dashboard.png)

> The Nextcloud dashboard is now running on the Raspberry Pi. Accessible from any browser on the home network. Recommended files, recent activity, and all features working.

### 3.9 — Fix 'Access through untrusted domain' error

This error appears when you try to access Nextcloud via Tailscale IP. Fix it by adding all your IPs to `trusted_domains`:

```bash
sudo nano /var/www/nextcloud/config/config.php
```

Use `Ctrl+W` to search for `trusted_domains`. Find that section and change it to look exactly like this:

```php
'trusted_domains' =>
array (
  0 => 'YOUR_LOCAL_IP',
  1 => 'YOUR_TAILSCALE_IP',
  2 => 'naspi.local',
),
```

Save: `Ctrl+X` → `Y` → `Enter`

```bash
sudo systemctl restart apache2
```

### 3.10 — Install Redis cache (makes Nextcloud faster and fixes file uploads)

> Redis is required for file locking to work. Without the correct Redis configuration, ALL file uploads fail with an 'Unknown error'.

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

Now add the Redis configuration to Nextcloud:
```bash
sudo nano /var/www/nextcloud/config/config.php
```

Find the closing `);` at the very bottom of the file. Add these lines BEFORE that `);`:

```php
'memcache.local' => '\OC\Memcache\APCu',
'memcache.locking' => '\OC\Memcache\Redis',
'redis' => [
    'host' => '127.0.0.1',
    'port' => 6379,
],
```

> ⚠️ **CRITICAL:** The host must be `127.0.0.1` and the port must be `6379`. Do NOT use the socket path `/var/run/redis/redis-server.sock` — that socket file does not exist in this setup and causes RedisException errors on every single file upload.

Save: `Ctrl+X` → `Y` → `Enter`

```bash
sudo systemctl restart apache2
```

### 3.11 — Set up automatic background tasks

```bash
sudo crontab -u www-data -e
```

If asked which editor → type `1` → Enter (this selects nano). Add these two lines at the very bottom:

```
*/5 * * * * php -f /var/www/nextcloud/cron.php
*/5 * * * * php /var/www/nextcloud/occ files:scan --all -q
```

Save: `Ctrl+X` → `Y` → `Enter`

What these two lines do:
- Line 1: Runs Nextcloud's internal background tasks every 5 minutes
- Line 2: Automatically rescans your files folder every 5 minutes — this means files added via Samba appear in Nextcloud automatically, no manual command ever needed

Now set background jobs to Cron in the Nextcloud web interface:
- Open `http://YOUR_LOCAL_IP/nextcloud` in Safari
- Click user icon (top right) → Administration Settings
- Scroll the left menu → Basic settings → Background jobs → select **Cron**

Both drives are now visible inside Nextcloud as separate folders:

![Nextcloud Files — both 4TB and 650GB drives visible as folders](images/nextcloud-files-both-drives.png)

> Both drives appear as separate clickable folders. The 4TB drive shows 519.8 GB used. The 650GB drive is accessible separately. Both are on the same Nextcloud account.

The Nextcloud activity log tracks all file changes automatically:

![Nextcloud Activity Log — showing automatic file tracking and iPhone backup activity](images/nextcloud-activity-log.png)

> The activity log shows all file creation, deletion, and modification events with timestamps. This proves the automatic background scan and iPhone auto-upload are both working correctly.

---

## Part 4 — Install Tailscale VPN (Secure Global Access)

> **INFO:** Tailscale creates a secure private encrypted tunnel between all your devices. You can access the Pi from anywhere in the world — no port forwarding on the router is needed. Free for personal use up to 100 devices.

### 4.1 — Create free Tailscale account

- Go to: https://tailscale.com → Get Started
- Sign up with Google, Apple, GitHub, or Microsoft account — no credit card needed
- Write down which account you used — **ALL devices must sign in with the same account**

### 4.2 — Install Tailscale on the Pi

```bash
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up
```

A URL appears on screen like: `https://login.tailscale.com/a/xxxxxxxxxx`
Copy that URL → open it in Safari on MacBook → log in with your Tailscale account → Pi is now registered.

```bash
sudo systemctl enable tailscaled
```

### 4.3 — Get your Pi's permanent Tailscale IP

```bash
tailscale ip -4
```

✅ This IP never changes even when your home internet IP changes. It is your permanent global address for the Pi.

### 4.4 — CRITICAL: Disable key expiry on Pi

> ⚠️ Without this step, Tailscale disconnects your Pi after 180 days and you cannot reconnect remotely without physical access to the Pi.

- Go to: https://login.tailscale.com/admin/machines
- Find `naspi` in the device list
- Click the three dots `...` next to naspi
- Click **Disable key expiry** → confirm

✅ Pi stays connected to Tailscale permanently.

### 4.5 — Install Tailscale on MacBook

- Go to: https://tailscale.com/download → Download for Mac → install
- Click Tailscale icon in menu bar (top right) → Log in → use the same Tailscale account
- Allow System Extension when the popup appears → click Install Now
- Then click Open Settings → System Settings opens → find Tailscale Network Extension → click Allow

✅ Tailscale icon in menu bar = VPN is active.

### 4.6 — Install Tailscale on iPhone

App Store → search **Tailscale** → install (by Tailscale Inc., free) → open → Sign in → same Tailscale account → turn the toggle ON

✅ iPhone can now reach Pi from anywhere — home WiFi, mobile data, hotel WiFi, abroad.

### 4.7 — Install Tailscale on Android

Play Store → search **Tailscale** → install → same account → toggle ON

### 4.8 — Install Tailscale on Windows

https://tailscale.com/download → Download for Windows → install → Sign in with same account → Tailscale icon appears in system tray (bottom right)

### 4.9 — Verify everything is connected

```bash
tailscale status
```

You should see all your devices listed with their Tailscale IPs.

**Test global access from iPhone:**
- Turn WiFi OFF on iPhone (Settings → WiFi → OFF) — now you are on mobile data only
- Make sure Tailscale is ON on iPhone
- Open Safari → go to: `http://YOUR_TAILSCALE_IP/nextcloud`
- You should see the Nextcloud login page from mobile data — global access confirmed working ✅
- Turn WiFi back ON when done testing

---

## Part 5 — Install Samba (Fast File Sharing — All Devices)

> **INFO:** Samba makes your 4TB drive appear as a normal network folder on MacBook Finder, iPhone Files app, Windows File Explorer, and Android. Samba and Nextcloud access the EXACT SAME FILES — there is no duplication at all.

### 5.1 — How Samba and Nextcloud share the same files

| Use Nextcloud when | Use Samba when |
|---|---|
| Accessing from another country | Transferring large files at home — faster |
| Auto photo backup from iPhone or Android | Drag and drop folders from MacBook |
| Sharing files with others via a link | Fast local access like a USB drive |
| Both methods access the exact same files | No duplication — no confusion |

Files added via Samba appear in Nextcloud automatically within 5 minutes — handled by the cron job set up in Part 3 Step 11.

### 5.2 — Install Samba

```bash
sudo apt update
sudo apt install samba samba-common-bin -y
smbd --version
```

### 5.3 — Back up original Samba config

```bash
sudo cp /etc/samba/smb.conf /etc/samba/smb.conf.backup
```

### 5.4 — Create new Samba configuration

```bash
sudo nano /etc/samba/smb.conf
```

Hold `Ctrl+K` repeatedly to delete all existing content line by line until the file is completely empty. Then paste this entire block exactly — replace `YOUR_NEXTCLOUD_ADMIN` and `YOUR_SAMBA_USERNAME` with your actual values:

```ini
[global]
workgroup = WORKGROUP
server string = RaspberryPi NAS
server role = standalone server
security = user
map to guest = never

# Required for macOS Tahoe 26.3 and iPhone compatibility
vfs objects = catia fruit streams_xattr
fruit:metadata = stream
fruit:model = RackMac
fruit:posix_rename = yes
fruit:nfs_aces = no
fruit:wipe_intentionally_left_blank_rfork = yes
fruit:delete_empty_adfiles = yes

[4TB]
comment = 4TB Hard Drive
path = /mnt/drive4tb/nextcloud-data/YOUR_NEXTCLOUD_ADMIN/files
browseable = yes
read only = no
create mask = 0664
directory mask = 0775
valid users = YOUR_SAMBA_USERNAME
force user = www-data
guest ok = no

[650GB]
comment = 650GB Hard Drive
path = /mnt/650GB
browseable = yes
read only = no
create mask = 0664
directory mask = 0775
valid users = YOUR_SAMBA_USERNAME
force user = www-data
guest ok = no
```

Save: `Ctrl+X` → `Y` → `Enter`

> ⚠️ `force user = www-data` is CRITICAL for both shares. It ensures all files created via Samba are owned by `www-data` — the same user Nextcloud uses. Without this, Nextcloud cannot read or see files you add via Samba.

> ⚠️ The `vfs objects = catia fruit streams_xattr` lines are REQUIRED for macOS Tahoe 26.3 and iPhone compatibility. Without them, Mac and iPhone may show shares as read-only or fail to connect entirely.

### 5.5 — Test config for errors

```bash
testparm
```

Look for: `Loaded services file OK.`

The line `Weak crypto is allowed by GnuTLS` is a harmless warning — ignore it completely.

### 5.6 — Create Samba password for your user

```bash
sudo smbpasswd -a YOUR_SAMBA_USERNAME
```

Type your chosen Samba password when asked, then type it again to confirm.

> ⚠️ The Samba password is completely separate from your SSH login password. Use this Samba password when connecting from MacBook Finder, iPhone Files app, Windows, or Android.

### 5.7 — Start Samba and enable auto-start on boot

```bash
sudo systemctl restart smbd
sudo systemctl restart nmbd
sudo systemctl enable smbd
sudo systemctl enable nmbd
```

Verify Samba is running:
```bash
sudo systemctl status smbd
```

Look for: `active (running)` and `smbd: ready to serve connections` ✅

---

## Part 6 — Accessing Files from All Devices

### 6.1 — MacBook — Nextcloud (browser)

| Where you are | Address to use |
|---|---|
| Home WiFi | `http://YOUR_LOCAL_IP/nextcloud` |
| Anywhere globally (Tailscale ON) | `http://YOUR_TAILSCALE_IP/nextcloud` |

Login: `YOUR_NEXTCLOUD_ADMIN` / `YOUR_NEXTCLOUD_PASSWORD`

### 6.2 — MacBook — Nextcloud Desktop App

- Download: https://nextcloud.com/install/#install-clients → macOS
- Install → open → Log in → server address: `http://YOUR_LOCAL_IP/nextcloud`
- A Nextcloud folder appears in Finder — drag any files or folders into it to sync automatically to 4TB drive

### 6.3 — MacBook — Samba (Finder)

**Home WiFi:**
- Finder → press `Command+K` → type: `smb://YOUR_LOCAL_IP` → click Connect
- Select Registered User → Username: `YOUR_SAMBA_USERNAME` → Password: `YOUR_SAMBA_PASSWORD`
- Select the `4TB` share → OK → it appears in Finder sidebar under Locations

**From anywhere globally:**
- Make sure Tailscale icon in menu bar shows as connected
- Finder → `Command+K` → type: `smb://YOUR_TAILSCALE_IP` → same login credentials

**Auto-reconnect after Mac restarts:**
System Settings → General → Login Items → click `+` → select the mounted drive

> See Samba connection photo in the images folder for reference.

### 6.4 — iPhone — Nextcloud App

App Store → search **Nextcloud** → install (by Nextcloud GmbH, free)
Open → Log in → server address: `http://YOUR_LOCAL_IP/nextcloud`

![iPhone Nextcloud App — showing both 4TB and 650GB drives as folders](images/iphone-nextcloud-drives.jpg)

> The Nextcloud iPhone app shows both drives as separate folders. The 4TB drive contains 519.79 GB of data. The 650GB drive is also accessible. Everything syncs automatically.

Tap into the 4TB folder to see all your files and subfolders:

![iPhone Nextcloud App — inside the 4TB folder showing all file categories](images/iphone-nextcloud-4tb.jpg)

> Inside the 4TB folder: Documents, GoogleDrive, iPhone Backup, Photos, Random, and Transferred Data folders — all accessible from the iPhone from anywhere.

**Set up Auto Photo Backup:**

![iPhone Nextcloud Auto Upload settings — automatically backing up camera roll to 4TB](images/iphone-auto-upload.jpg)

> Tap menu → Settings → Auto Upload → turn ON. Photos automatically back up to the `/4TB/YOUR_IPHONE_BACKUP/` folder whenever connected to any internet. Destination, upload settings, and backup schedule are all configurable.

### 6.5 — iPhone — Samba (Files App)

- Open Files app → tap Browse at the bottom
- Tap three dots `...` (top right) → Connect to Server
- Home WiFi: `smb://YOUR_LOCAL_IP` OR Global: `smb://YOUR_TAILSCALE_IP` (Tailscale must be ON)
- Tap Connect → Registered User → Name: `YOUR_SAMBA_USERNAME` → Password: `YOUR_SAMBA_PASSWORD` → Next
- You will see: `4TB` and `650GB` — tap either to browse files
- They save under Browse → Shared for quick future access

### 6.6 — Android — Nextcloud App

Play Store → search **Nextcloud** → install (free)
Log in → server: `http://YOUR_LOCAL_IP/nextcloud` → your admin credentials
Auto photo backup: Menu → Settings → Auto Upload → enable

### 6.7 — Android — Samba (CX File Explorer)

Play Store → search **CX File Explorer** → install (free)
Open → tap Network at bottom → tap `+` → New Location → SMB
Server: `YOUR_LOCAL_IP` (home) or `YOUR_TAILSCALE_IP` (global, Tailscale ON)
Username: `YOUR_SAMBA_USERNAME` → Password: `YOUR_SAMBA_PASSWORD` → OK

### 6.8 — Windows — Nextcloud Desktop App

Download: https://nextcloud.com/install/#install-clients → Windows
Install → server: `http://YOUR_LOCAL_IP/nextcloud` → your admin credentials
Enable **Virtual Files** mode to save local disk space — files appear but only download when opened

### 6.9 — Windows — Samba (File Explorer)

- Open File Explorer → right-click **This PC** → **Map network drive**
- Drive letter: `Z:` → Folder: `\\YOUR_LOCAL_IP\4TB` → check **Reconnect at sign-in** → Finish
- Enter: `YOUR_SAMBA_USERNAME` / `YOUR_SAMBA_PASSWORD` → OK
- Repeat for drive `Y:` with `\\YOUR_LOCAL_IP\650GB`
- For global access: use `\\YOUR_TAILSCALE_IP\4TB` (Tailscale icon in tray must be ON)

---

## Part 7 — Transferring Files to Your NAS

### 7.1 — MacBook — Upload via Nextcloud browser

Open `http://YOUR_LOCAL_IP/nextcloud` in Safari → click `+ New` button → Upload file → select file

> ⚠️ Browser upload only supports individual files, not entire folders. For folders use Method 7.2 or 7.3.

### 7.2 — MacBook — Sync folders via Nextcloud Desktop App

Drag any folder into the Nextcloud folder in Finder → syncs automatically — entire folder structure preserved.
This is the best method for regular MacBook → NAS file sync.

### 7.3 — MacBook — Drag and drop via Samba (Finder)

Mount `smb://YOUR_LOCAL_IP` in Finder → open two Finder windows side by side → drag and drop files directly.
Files appear in Nextcloud automatically within 5 minutes.

### 7.4 — iPhone — Upload via Nextcloud App

Nextcloud app → tap Files → tap `+` (top right) → Upload file → choose from Photos or Files
Auto photo backup: Menu → Settings → Auto Upload → turn ON — photos back up automatically whenever connected.

### 7.5 — iPhone — Copy files via Samba (Files App)

Files app → Browse → Shared → tap your NAS share
Long-press any file → Share → Save to Files → choose NAS as destination → Save

### 7.6 — Android — Upload via Nextcloud App

Nextcloud app → tap `+` (bottom right) → Upload content → choose files → Upload

### 7.7 — Android — Copy files via Samba (CX File Explorer)

CX File Explorer → Network → tap your NAS connection → navigate to destination folder → tap copy/paste icon

### 7.8 — Windows — Upload via Nextcloud Desktop App

Drag any file or folder into the Nextcloud folder on Windows → syncs automatically to 4TB HDD.

### 7.9 — Windows — Copy files via Samba (File Explorer)

Open Z: drive in File Explorer → drag and drop files directly from Windows into the Z: drive.
For global access: Tailscale must be ON in system tray first.

Your 4TB drive showing all transferred file categories in Nextcloud:

![Nextcloud 4TB folder — showing Documents, GoogleDrive, iPhone Backup, Photos, Random, Transferred Data](images/nextcloud-4tb-contents.png)

> The 4TB folder contains 6 subfolders with a total of 519.8 GB of data — including a full GoogleDrive sync (188 GB), transferred data (328 GB), iPhone backup, photos, and documents.

### 7.10 — Direct Pi-to-Pi copy (fastest for large transfers)

This copies directly inside the Pi — it does not go through WiFi at all. MacBook can sleep, terminal can close — Pi keeps copying by itself.

```bash
sudo nohup rsync -av --chown=www-data:www-data \
  /mnt/SOURCE-FOLDER/ \
  /mnt/drive4tb/nextcloud-data/YOUR_NEXTCLOUD_ADMIN/files/4TB/DESTINATION-FOLDER/ \
  > /home/YOUR_SSH_USERNAME/copy-progress.log 2>&1 &
```

Replace `SOURCE-FOLDER` with your actual source path and `DESTINATION-FOLDER` with your folder name inside 4TB.

You will see a number like `[1] 12345` — this means it is running in the background. You can now close the terminal and sleep your MacBook.

**Check progress anytime:**
```bash
tail -f /home/YOUR_SSH_USERNAME/copy-progress.log
```
Press `Ctrl+C` to stop watching — the copy keeps running.

**Check if still running:**
```bash
ps aux | grep rsync
```

**After copy finishes — tell Nextcloud about all new files:**
```bash
sudo -u www-data php /var/www/nextcloud/occ files:scan --all
```

---

## Part 8 — Security Setup

### 8.1 — Install and configure UFW firewall

> ⚠️ You must add the SSH rule FIRST before enabling UFW. If you enable UFW without the SSH rule, you will be permanently locked out of your Pi remotely.

```bash
sudo apt install ufw -y
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 22/tcp
sudo ufw allow from 192.168.0.0/24 to any port 139 proto tcp
sudo ufw allow from 192.168.0.0/24 to any port 445 proto tcp
sudo ufw allow 80/tcp
sudo ufw allow 41641/udp
sudo ufw enable
sudo ufw status verbose
```

> Note: Replace `192.168.0.0/24` with your actual home network range if it is different.

The rules explained:
- Port 22: SSH access — allows you to connect remotely
- Ports 139, 445: Samba — allows file sharing on home network only
- Port 80: HTTP — allows Nextcloud access in browser
- Port 41641/udp: Tailscale — allows VPN tunnel

### 8.2 — Enable automatic security updates

```bash
sudo apt install unattended-upgrades -y
sudo dpkg-reconfigure --priority=low unattended-upgrades
```

Select **YES** when prompted. This automatically installs security patches without you needing to do anything.

### 8.3 — Monthly manual update (do once a week or month)

```bash
sudo apt update && sudo apt upgrade -y
```

### 8.4 — Enable Automatic Weekly Updates if you don't want manual update

```bash
sudo nano /etc/apt/apt.conf.d/20auto-upgrades
```

Make sure it contains exactly:
```
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
APT::Periodic::AutocleanInterval "7";
```

Save: `Ctrl+X` → `Y` → `Enter`

```bash
sudo nano /etc/apt/apt.conf.d/50unattended-upgrades
```

Find this line and change it:
```
Unattended-Upgrade::Automatic-Reboot "true";
Unattended-Upgrade::Automatic-Reboot-Time "04:00";
```

Save: `Ctrl+X` → `Y` → `Enter`

```bash
sudo systemctl restart unattended-upgrades
```

Verify it is running:
```bash
sudo systemctl status unattended-upgrades
```

Look for: `active (running)` ✅

---

## Part 9 — Troubleshooting Common Issues

### 9.1 — File upload fails with Unknown error or RedisException

**Cause:** Redis socket path is wrong in config.php

**Fix:**
```bash
sudo nano /var/www/nextcloud/config/config.php
```

Make sure the Redis section looks exactly like this:
```php
'memcache.locking' => '\OC\Memcache\Redis',
'redis' => [
    'host' => '127.0.0.1',
    'port' => 6379,
],
```

```bash
sudo systemctl restart apache2
```

### 9.2 — Access through untrusted domain error

**Cause:** Your IP is not in `trusted_domains` in config.php
**Fix:** See Part 3 Step 9 — add your IPs to the trusted_domains array

### 9.3 — Nextcloud browser redirect fails after install

**Cause:** Chrome strips the IP address from the redirect URL
**Fix:** Open Safari and manually type: `http://YOUR_LOCAL_IP/nextcloud`

### 9.4 — Drive not mounting after reboot

```bash
sudo cat /etc/fstab
sudo mount -a
```

Check for error messages. Most common cause: wrong UUID in fstab or missing `nofail` option.

### 9.5 — Samba connection refused or cannot connect

```bash
sudo systemctl status smbd
sudo systemctl restart smbd
testparm
```

If `testparm` shows errors — check your smb.conf for typos. Make sure no lines are missing.

### 9.6 — Cannot find Pi on network after reboot

```bash
ping naspi.local
```

If no reply — check router admin page for the current IP. Use that IP to SSH in.

### 9.7 — Files added via Samba not appearing in Nextcloud

Wait 5 minutes — the automatic rescan runs every 5 minutes. Or trigger it manually right now:
```bash
sudo -u www-data php /var/www/nextcloud/occ files:scan --all
```

### 9.8 — Perl locale warnings during Samba enable

These warnings are completely harmless — they do not affect functionality. Samba works perfectly despite them. You can fix them with:
```bash
sudo locale-gen en_GB.UTF-8
sudo update-locale LANG=en_GB.UTF-8
```

### 9.9 — If 9.7 not working, Nextcloud scan stuck with "Another process is already scanning"

This happens when a previous scan was interrupted and left a lock in Redis cache:
```bash
sudo redis-cli FLUSHALL
sudo -u www-data php /var/www/nextcloud/occ files:scan --all
```

---

## Part 10 — Complete Quick Reference Card

### 10.1 — All Access Addresses

| Device and Service | Home WiFi Address | Global Address (Tailscale ON) |
|---|---|---|
| Any browser — Nextcloud | `http://YOUR_LOCAL_IP/nextcloud` | `http://YOUR_TAILSCALE_IP/nextcloud` |
| MacBook Finder — Samba | `smb://YOUR_LOCAL_IP` | `smb://YOUR_TAILSCALE_IP` |
| iPhone Files app — Samba | `smb://YOUR_LOCAL_IP` | `smb://YOUR_TAILSCALE_IP` |
| Android CX File Explorer | `YOUR_LOCAL_IP` (server field) | `YOUR_TAILSCALE_IP` (server field) |
| Windows File Explorer | `\\YOUR_LOCAL_IP\4TB` | `\\YOUR_TAILSCALE_IP\4TB` |
| SSH from MacBook / Terminal | `ssh YOUR_SSH_USERNAME@YOUR_LOCAL_IP` | `ssh YOUR_SSH_USERNAME@YOUR_TAILSCALE_IP` |
| SSH from iPhone (Termius) | Host: `YOUR_LOCAL_IP` | Host: `YOUR_TAILSCALE_IP` |

### 10.2 — Important File and Folder Paths

| What | Full path |
|---|---|
| 4TB HDD mount point | `/mnt/drive4tb` |
| 650GB HDD mount point | `/mnt/650GB` |
| Nextcloud data folder | `/mnt/drive4tb/nextcloud-data` |
| 4TB files — Nextcloud and Samba | `/mnt/drive4tb/nextcloud-data/YOUR_NEXTCLOUD_ADMIN/files/4TB` |
| 650GB files — Nextcloud and Samba | `/mnt/drive4tb/nextcloud-data/YOUR_NEXTCLOUD_ADMIN/files/650GB` |
| Nextcloud web application | `/var/www/nextcloud` |
| Nextcloud config file | `/var/www/nextcloud/config/config.php` |
| Samba config file | `/etc/samba/smb.conf` |
| PHP config file | `/etc/php/8.3/apache2/php.ini` |
| Apache Nextcloud config | `/etc/apache2/sites-available/nextcloud.conf` |
| Drive mount config | `/etc/fstab` |
| fstab backup | `/etc/fstab.backup` |
| File copy progress log | `/home/YOUR_SSH_USERNAME/copy-progress.log` |
| GDrive auto-sync log | `/home/YOUR_SSH_USERNAME/gdrive-auto-sync.log` |

### 10.3 — All Essential Terminal Commands

| What you want to do | Command |
|---|---|
| Check drives mounted and how full | `df -h \| grep /mnt` |
| See all drives connected | `lsblk` |
| Find UUID of drives | `sudo blkid` |
| Is Nextcloud web server running? | `sudo systemctl status apache2` |
| Is Samba running? | `sudo systemctl status smbd` |
| Is Redis cache running? | `sudo systemctl status redis-server` |
| Is Tailscale connected? | `tailscale status` |
| What is my Tailscale IP? | `tailscale ip -4` |
| Restart Nextcloud | `sudo systemctl restart apache2` |
| Restart Samba | `sudo systemctl restart smbd` |
| Restart Redis | `sudo systemctl restart redis-server` |
| Rescan files for Nextcloud manually | `sudo -u www-data php /var/www/nextcloud/occ files:scan --all` |
| Start a background file copy | `sudo nohup rsync -av --chown=www-data:www-data /mnt/SOURCE/ /mnt/drive4tb/nextcloud-data/YOUR_NEXTCLOUD_ADMIN/files/4TB/DESTINATION/ > /home/YOUR_SSH_USERNAME/copy-progress.log 2>&1 &` |
| Check copy progress | `tail -f /home/YOUR_SSH_USERNAME/copy-progress.log` |
| Is rsync copy still running? | `ps aux \| grep rsync` |
| Update all software (monthly) | `sudo apt update && sudo apt upgrade -y` |
| Reboot Pi safely | `sudo reboot` |
| Shut Pi down safely | `sudo shutdown -h now` |
| Edit Nextcloud config | `sudo nano /var/www/nextcloud/config/config.php` |
| Edit Samba config | `sudo nano /etc/samba/smb.conf` |
| Edit drive mount config | `sudo nano /etc/fstab` |
| Test Samba config for errors | `testparm` |
| Check firewall rules | `sudo ufw status verbose` |

---

## Part 11 — Shutdown, Restart and Daily Use

> **Why shut down when not using it?** Saves electricity. Reduces HDD wear — HDDs have a limited number of running hours. Extends the life of your Pi and drives significantly.

### 11.1 — How to Shut Down Safely (ALWAYS follow this order)

> ⚠️ NEVER just pull the power cable or switch off the dock while the Pi is running. This can corrupt files on your HDDs and damage the microSD card.

**Step 1 — SSH into your Pi:**
```bash
ssh YOUR_SSH_USERNAME@YOUR_LOCAL_IP
```

**Step 2 — Run the shutdown command:**
```bash
sudo shutdown -h now
```

**Step 3 — Watch the Pi LEDs:**
- Green LED will flash a few times then go **OFF completely**
- Red LED stays ON — this is normal, it just means power is still connected
- Wait **30 full seconds** after the green LED goes off

**Step 4 — Turn off the docking station:**
- Flip the power switch on the BACK of the dock to OFF
- Both HDD lights on the dock will turn off

✅ Shutdown is complete.

| Action | Safe? |
|---|---|
| `sudo shutdown -h now` → wait for LED → turn off dock | ✅ YES — always do this |
| Pull Pi power cable while running | ❌ NO — can corrupt files |
| Turn off dock switch while Pi is running | ❌ NO — can corrupt drives |

### 11.2 — How to Power On (ALWAYS follow this order)

1. Flip dock power switch to ON → wait **10 seconds** for drives to spin up
2. Connect Pi USB-C power cable
3. Wait **60–90 seconds** — do not try to connect before this
4. Access files via browser, Finder, or app — everything ready

### 11.3 — Everything Starts Automatically — No Commands Needed

When the Pi boots, ALL services start by themselves:

| Service | Status after boot |
|---|---|
| Drive mounts (4TB and 650GB) | Auto-mounted via fstab |
| Nextcloud (Apache web server) | Auto-starts — accessible immediately |
| Samba file sharing | Auto-starts — Finder/Files app connects instantly |
| Redis cache | Auto-starts — Nextcloud performs at full speed |
| Tailscale VPN | Auto-starts — global access available immediately |
| Background file scan (cron) | Auto-runs every 5 minutes |

### 11.4 — Access Your Data After Boot

Wait 60–90 seconds after powering on, then access your files any of these ways:

| Device and Method | What to do |
|---|---|
| MacBook — Nextcloud browser | Open Safari → `http://YOUR_LOCAL_IP/nextcloud` → login: your admin credentials |
| MacBook — Finder (Samba) | Finder → `Command+K` → `smb://YOUR_LOCAL_IP` → your Samba credentials |
| iPhone — Nextcloud app | Just open the app — it reconnects automatically |
| iPhone — Files app (Samba) | Files → Browse → Shared → tap your NAS share |
| Android — Nextcloud app | Open app — reconnects automatically |
| Windows — File Explorer | Open Z: drive (mapped) — reconnects automatically |
| Global from anywhere | Turn Tailscale ON on your device → use `YOUR_TAILSCALE_IP` instead of `YOUR_LOCAL_IP` |

### 11.5 — Quick Shutdown and Startup Summary Card

**SHUTDOWN ORDER — Do this EVERY time:**
1. `ssh YOUR_SSH_USERNAME@YOUR_LOCAL_IP`
2. `sudo shutdown -h now`
3. Wait 30 seconds for green LED to go OFF
4. Turn off RSHTECH dock power switch

**STARTUP ORDER — Do this EVERY time:**
1. Turn ON dock power switch → wait 10 seconds
2. Connect Pi USB-C power cable
3. Wait 60–90 seconds for full boot
4. Access files via browser, Finder, or app — everything ready!

✅ Your NAS is now fully set up for safe long-term use. Shut it down whenever not needed to save electricity and extend HDD life. Power on only when you need it.

### 11.6 — Auto-Restart Services if They Crash

These commands make each service restart automatically within 10 seconds if it crashes — without needing to reboot the whole Pi. This is a one-time setup.

**Nextcloud (Apache):**
```bash
sudo mkdir -p /etc/systemd/system/apache2.service.d/
sudo nano /etc/systemd/system/apache2.service.d/override.conf
```
Paste:
```ini
[Service]
Restart=always
RestartSec=10
```
Save: `Ctrl+X` → `Y` → `Enter`

**Samba:**
```bash
sudo mkdir -p /etc/systemd/system/smbd.service.d/
sudo nano /etc/systemd/system/smbd.service.d/override.conf
```
Paste:
```ini
[Service]
Restart=always
RestartSec=10
```
Save: `Ctrl+X` → `Y` → `Enter`

**Redis:**
```bash
sudo mkdir -p /etc/systemd/system/redis-server.service.d/
sudo nano /etc/systemd/system/redis-server.service.d/override.conf
```
Paste:
```ini
[Service]
Restart=always
RestartSec=10
```
Save: `Ctrl+X` → `Y` → `Enter`

Apply all changes:
```bash
sudo systemctl daemon-reload
sudo systemctl restart apache2
sudo systemctl restart smbd
sudo systemctl restart redis-server
```

Verify it worked:
```bash
sudo systemctl show apache2 | grep Restart
sudo systemctl show smbd | grep Restart
sudo systemctl show redis-server | grep Restart
```

You should see `Restart=always` for all three. ✅

---

## Part 12 — Troubleshooting Unexpected Shutdowns

Most common causes: overheating, undervoltage from weak power supply, heavy workload using too much RAM, or a kernel crash.

### 12.1 — Enable Persistent Logs (do this first — one time only)

By default, Raspberry Pi OS does not save logs after a reboot. This means after an unexpected shutdown, all evidence of what caused it is deleted. Enable persistent logs so crash information survives reboots.

```bash
sudo sed -i 's/#Storage=persistent/Storage=persistent/' /etc/systemd/journald.conf
grep Storage /etc/systemd/journald.conf
```

You should see: `Storage=persistent` (without the `#` symbol).

```bash
sudo mkdir -p /var/log/journal/$(cat /etc/machine-id)
sudo systemctl restart systemd-journald
sudo reboot
```

After reboot — verify logs folder exists:
```bash
ls /var/log/journal/
```

✅ You should see a folder with a long ID. Persistent logs are now active permanently.

### 12.2 — Check Temperature

```bash
vcgencmd measure_temp
```

| Temperature | What it means and what to do |
|---|---|
| 40°C – 60°C | ✅ Perfect — normal operating temperature |
| 60°C – 70°C | Warm but acceptable — ensure open airflow around Pi |
| 70°C – 80°C | Hot — add heatsink immediately |
| 80°C+ | CRITICAL — Pi will throttle and may shut down — add heatsink and fan urgently |

If overheating: add a heatsink on the Pi CPU chip (2–5 EUR), add a small 5V fan, ensure Pi is NOT in a closed box, keep it away from other heat sources.

### 12.3 — Check Power Supply (Undervoltage)

```bash
vcgencmd get_throttled
```

| Result | Meaning |
|---|---|
| `throttled=0x0` | ✅ Power supply is perfect — no issues |
| `throttled=0x50005` | ⚠️ Undervoltage detected — replace power supply immediately |
| `throttled=0x80008` | ⚠️ Overheating detected — add heatsink and fan |
| `throttled=0x50050005` | ⚠️ Both undervoltage AND overheating — fix both |

> Always use the official Raspberry Pi 4 USB-C Power Supply: 5.1V 3A. Never use a phone charger — they cannot provide stable 3A continuously.

### 12.4 — Read Crash Logs After Unexpected Shutdown

```bash
sudo journalctl -b -1 --no-pager | tail -100
```

| Part of command | What it means |
|---|---|
| `-b -1` | Look at the PREVIOUS boot — before the current reboot |
| `--no-pager` | Show output directly in terminal without scrolling |
| `tail -100` | Show only the last 100 lines — the most important part near shutdown time |

What to look for in the logs:

| Log message contains | Cause and fix |
|---|---|
| `Out of memory` / `OOM` / `Kill process` | Pi ran out of RAM — reduce transfers or add swap |
| `Under-voltage detected` | Weak power supply — replace with official 5.1V 3A charger |
| `Thermal throttling` / `temperature` | Overheating — add heatsink and fan |
| `kernel panic` | Serious crash — check microSD for corruption |

### 12.5 — Fix Locale Warnings

When SSHing into Pi you may see repeated warnings like: `setlocale: LC_CTYPE: cannot change locale (UTF-8)`. These are completely harmless and do not affect Nextcloud, Samba, or any other service. To fix them:

```bash
sudo locale-gen en_GB.UTF-8
sudo update-locale LANG=en_GB.UTF-8
sudo reboot
```

After reboot SSH back in — the locale warnings should be gone.

> **IMPORTANT:** If locale warnings still appear after reboot — ignore them completely. All NAS services work perfectly regardless.

### 12.6 — Verify All Services After Unexpected Shutdown

After Pi restarts following an unexpected shutdown, always verify all services are running:

```bash
sudo systemctl status apache2
sudo systemctl status smbd
sudo systemctl status redis-server
tailscale status
df -h | grep /mnt
```

| What you see | What it means |
|---|---|
| `active (running)` shown in green | Service is running correctly ✅ |
| `failed` or `inactive (dead)` | Service crashed — restart it manually |
| Both drives listed in `df -h` | Drives mounted correctly ✅ |
| Drive missing from `df -h` | Drive did not mount — run: `sudo mount -a` |

Restart any service that shows `failed`:
```bash
sudo systemctl restart apache2
sudo systemctl restart smbd
sudo systemctl restart redis-server
```

If a drive is missing from `df -h`:
```bash
sudo mount -a
```

### 12.7 — All Diagnostic Commands Quick Reference

| What to check | Command to run |
|---|---|
| Current Pi temperature | `vcgencmd measure_temp` |
| Power supply health | `vcgencmd get_throttled` |
| Crash logs from previous boot | `sudo journalctl -b -1 --no-pager \| tail -100` |
| Logs from current boot | `sudo journalctl -b --no-pager \| tail -50` |
| Nextcloud running? | `sudo systemctl status apache2` |
| Samba running? | `sudo systemctl status smbd` |
| Redis running? | `sudo systemctl status redis-server` |
| Drives mounted? | `df -h \| grep /mnt` |
| Mount missing drives | `sudo mount -a` |
| Restart Nextcloud | `sudo systemctl restart apache2` |
| Restart Samba | `sudo systemctl restart smbd` |
| Restart Redis | `sudo systemctl restart redis-server` |

> ✅ **Enable persistent logs in 12.1 immediately — before any problem occurs. This is the single most important diagnostic tool for your NAS.**

---

## Part 13 — Transfer Files from Google Drive to Nextcloud

> **How it works:** Google Drive → rclone running on Pi → 4TB HDD. The Pi handles the entire transfer by itself. Nothing is downloaded to your MacBook. Your MacBook can sleep during the transfer.

### 13.1 — Install rclone on MacBook (one time only — needed for authorization)

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install rclone
rclone version
```

You should see a version number like `rclone v1.73.1` ✅

**On Windows:** Download from https://rclone.org/downloads/ → extract zip → open PowerShell in that folder.

### 13.2 — Install rclone on Pi

```bash
sudo apt install rclone -y
```

### 13.3 — Configure Google Drive connection on Pi

```bash
rclone config
```

Answer each question exactly as shown:

| Question shown | Your answer |
|---|---|
| `n/s/q>` | `n` → Enter (create new remote) |
| `name>` | `googledrive` → Enter |
| Storage type | search for `drive` → Enter |
| `client_id>` | Press Enter (leave blank) |
| `client_secret>` | Press Enter (leave blank) |
| `scope>` (list of options) | `1` → Enter (full access) |
| `root_folder_id>` | Press Enter (leave blank) |
| `service_account_file>` | Press Enter (leave blank) |
| Edit advanced config? | `n` → Enter |
| Use auto config? | `n` → Enter — **IMPORTANT: always choose n on the Pi** |

Pi then shows a command like this — copy the ENTIRE line exactly:
```
rclone authorize "drive" "YOUR_AUTH_CODE_HERE"
```

### 13.4 — Authorize Google Drive on MacBook

Keep the Pi terminal open. Open a NEW Terminal window on your MacBook.
Paste the exact command Pi showed you into MacBook Terminal → press Enter.
A browser window opens automatically → sign in with your Google account → click Allow.
MacBook Terminal shows a very long code starting with `eyJ...` — copy the ENTIRE code.
Go back to Pi terminal → at `config_token>` paste the entire code → press Enter.

Then answer:
- Configure as Shared Drive? → `n` → Enter
- Keep this remote? → `y` → Enter
- Quit config → `q` → Enter

### 13.5 — Copy rclone config to root (CRITICAL step)

Because we use `sudo` for the actual file transfer, the config must be copied to root's location. Without this the transfer fails with a "config file not found" error.

```bash
sudo mkdir -p /root/.config/rclone
sudo cp /home/YOUR_SSH_USERNAME/.config/rclone/rclone.conf /root/.config/rclone/rclone.conf
sudo rclone listremotes
```

✅ You should see: `googledrive:` — Google Drive is connected and ready.

### 13.6 — Test Google Drive connection

```bash
rclone ls googledrive: --max-depth 1
```

You will see all your Google Drive files and folders listed. ✅

### 13.7 — Create destination folder on 4TB drive

```bash
sudo mkdir -p /mnt/drive4tb/nextcloud-data/YOUR_NEXTCLOUD_ADMIN/files/4TB/GoogleDrive
sudo chown -R www-data:www-data /mnt/drive4tb/nextcloud-data/YOUR_NEXTCLOUD_ADMIN/files/4TB/GoogleDrive
```

### 13.8 — Transfer specific folders from Google Drive

> ⚠️ Transfer ONE folder at a time. Wait for each to finish before starting the next.

```bash
sudo nohup rclone copy "googledrive:YOUR_FOLDER_NAME" \
  /mnt/drive4tb/nextcloud-data/YOUR_NEXTCLOUD_ADMIN/files/4TB/GoogleDrive/YOUR_FOLDER_NAME/ \
  --transfers=4 --checkers=8 --drive-chunk-size=64M -v \
  > /home/YOUR_SSH_USERNAME/gdrive-copy.log 2>&1 &
```

For folder names with spaces — put them in quotes: `"googledrive:Travel 2025"`

You will see a number like `[1] 18017` — running in background. MacBook can sleep now.

### 13.9 — Check transfer progress

```bash
tail -f /home/YOUR_SSH_USERNAME/gdrive-copy.log
```

Press `Ctrl+C` to stop watching — the transfer keeps running in background.

### 13.10 — If transfer gets interrupted — resume it

rclone is smart — it never copies already transferred files again. Simply run the same command again — it skips completed files and continues from where it stopped.

### 13.11 — Make files appear in Nextcloud after transfer

```bash
sudo -u www-data php /var/www/nextcloud/occ files:scan --all
```

Open `http://YOUR_LOCAL_IP/nextcloud` → Files → 4TB → GoogleDrive to see all transferred files. ✅

### 13.12 — Verify transfer is complete

**Step 1 — Check if transfer is still running:**
```bash
ps aux | grep rclone
```

If you see only `grep --color=auto rclone` — transfer is completely finished. ✅
If you see a long rclone line — still running, wait and check again later.

**Step 2 — Check how many files were transferred:**
```bash
sudo find /mnt/drive4tb/nextcloud-data/YOUR_NEXTCLOUD_ADMIN/files/4TB/GoogleDrive/ -type f | wc -l
```

This shows the total number of files. Compare with your Google Drive folder to confirm everything transferred.

**Step 3 — Check total size transferred:**
```bash
sudo du -sh /mnt/drive4tb/nextcloud-data/YOUR_NEXTCLOUD_ADMIN/files/4TB/GoogleDrive/
```

Compare this number with the folder size shown in Google Drive. They should match.

**Step 4 — Check the transfer log for any errors:**
```bash
cat /home/YOUR_SSH_USERNAME/gdrive-copy.log | grep -i error
```

If nothing shows — no errors during transfer. ✅
If errors show — run the transfer command again. rclone will skip already copied files and retry only the failed ones.

**Step 5 — Make all transferred files appear in Nextcloud:**
```bash
sudo -u www-data php /var/www/nextcloud/occ files:scan --all
```

After this open `http://YOUR_LOCAL_IP/nextcloud` → Files → 4TB → GoogleDrive folder — all files will be visible. ✅

### 13.13 — Quick reference for future transfers

| What | Command |
|---|---|
| Test Google Drive connection | `rclone ls googledrive: --max-depth 1` |
| Transfer specific folder | `sudo nohup rclone copy "googledrive:FolderName" /mnt/drive4tb/nextcloud-data/YOUR_NEXTCLOUD_ADMIN/files/4TB/GoogleDrive/FolderName/ --transfers=4 --checkers=8 --drive-chunk-size=64M -v > /home/YOUR_SSH_USERNAME/gdrive-copy.log 2>&1 &` |
| Watch live progress | `tail -f /home/YOUR_SSH_USERNAME/gdrive-copy.log` |
| Check size copied so far | `sudo du -sh /mnt/drive4tb/nextcloud-data/YOUR_NEXTCLOUD_ADMIN/files/4TB/GoogleDrive/` |
| Is transfer still running? | `ps aux \| grep rclone` |
| Scan files into Nextcloud | `sudo -u www-data php /var/www/nextcloud/occ files:scan --all` |
| Count transferred files | `sudo find /mnt/drive4tb/nextcloud-data/YOUR_NEXTCLOUD_ADMIN/files/4TB/GoogleDrive/ -type f \| wc -l` |

---

## Part 3.14 — Speed Optimizations for Nextcloud

Run these steps after Nextcloud is fully installed and working. They make Nextcloud significantly faster for all devices — especially photo browsing and global access.

### Step 1 — Enable HTTP/2

```bash
sudo a2enmod http2
sudo systemctl restart apache2
```

### Step 2 — Fix database and run maintenance

```bash
sudo -u www-data php /var/www/nextcloud/occ db:add-missing-indices
sudo -u www-data php /var/www/nextcloud/occ db:add-missing-primary-keys
sudo -u www-data php /var/www/nextcloud/occ maintenance:repair
```

### Step 3 — Install and run preview generator

```bash
sudo -u www-data php /var/www/nextcloud/occ app:install previewgenerator
```

Run once to generate previews for all existing files. This runs in the background and takes several hours depending on how many files you have:

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

If you see only the `grep` line — it is finished. ✅

### Step 4 — Add preview cron so new files get previews automatically

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

## Part 14 — Automation

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

### 14.1 — Auto Config Backup (Every Sunday 3:00 AM)

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

echo "Config backup completed: $DATE"
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

### 14.2 — Auto Drive Health Check (Every Sunday 4:00 AM)

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
> SMART health reading through USB dock is not guaranteed on all RSHTECH models. You must run the test commands above first. If they return PASSED — everything works. If they return an error — SMART is not supported through your dock and sections 14.2 and the SMART parts of 14.7 should be skipped.

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

### 14.3 — Auto Log Cleanup (Every Sunday 5:00 AM)

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

### 14.4 — Auto Nextcloud Database Optimization (Every Sunday 6:00 AM)

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

echo "Database optimization completed: $(date '+%Y-%m-%d %H:%M:%S')"
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

### 14.5 — Auto Nextcloud File Scan

Already set up in Part 3.11 — runs every 5 minutes automatically. Nothing to do. ✅

### 14.6 — Auto Google Drive Sync (Every Night 2:00 AM)

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

> ⚠️ If you want to sync more Google Drive folders — add another `rclone copy` line inside the script for each folder using the same format.

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

### 14.7 — Auto Email Health Alert (Every 6 Hours)

Monitors your NAS every 6 hours and sends you an email alert ONLY when a problem is detected. No email = everything is fine. You will be alerted if: temperature is too high, a drive is not mounted, a service has crashed, or 4TB drive is more than 90% full.

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
    echo "Alert email sent: $(date '+%Y-%m-%d %H:%M:%S')"
else
    echo "Health check passed — no issues detected: $(date '+%Y-%m-%d %H:%M:%S')"
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

### 14.8 — Verify All Automation is Set Up Correctly

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

**Check Nextcloud file scan cron (runs separately as www-data):**
```bash
sudo crontab -u www-data -l
```

You should see these 2 lines:
```
*/5 * * * * php -f /var/www/nextcloud/cron.php
*/5 * * * * php /var/www/nextcloud/occ files:scan --all -q
```

✅ All 7 automations confirmed running. Your NAS is now fully automated.

---

## Part 15 — Custom Domain: YOUR_HOSTNAME.nas

One name for everything — works at home and anywhere in the world via Tailscale.

| Instead of this (old) | Use this (new) — works everywhere |
|---|---|
| `http://YOUR_LOCAL_IP/nextcloud` (home only) | `http://YOUR_HOSTNAME.nas/nextcloud` |
| `http://YOUR_TAILSCALE_IP/nextcloud` (outside only) | `http://YOUR_HOSTNAME.nas/nextcloud` |
| `smb://YOUR_LOCAL_IP` (home only) | `smb://YOUR_HOSTNAME.nas` |
| `smb://YOUR_TAILSCALE_IP` (outside only) | `smb://YOUR_HOSTNAME.nas` |
| `ssh YOUR_SSH_USERNAME@YOUR_LOCAL_IP` | `ssh YOUR_SSH_USERNAME@YOUR_HOSTNAME.nas` |

> 💡 Old IP addresses still work as backup always. The custom domain is added on top — nothing is removed or broken.

### 15.1 — Install DNS Server on Pi (dnsmasq)

SSH into Pi and run:

```bash
sudo apt install dnsmasq -y
sudo nano /etc/dnsmasq.conf
```

Scroll to the very bottom of the file and add exactly these 5 lines — replace `YOUR_HOSTNAME` with your chosen name, `YOUR_LOCAL_IP` with your Pi's local IP, and `YOUR_TAILSCALE_IP` with your Pi's Tailscale IP:

```
address=/YOUR_HOSTNAME.nas/YOUR_LOCAL_IP
domain-needed
bogus-priv
listen-address=YOUR_LOCAL_IP,YOUR_TAILSCALE_IP
bind-interfaces
```

Save: `Ctrl+X` → `Y` → `Enter`

```bash
sudo systemctl restart dnsmasq
sudo systemctl enable dnsmasq
```

> ⚠️ **CRITICAL:** `listen-address` must have BOTH IPs separated by a comma. Without `YOUR_TAILSCALE_IP`, the custom domain breaks when Tailscale is ON.

### 15.2 — Add Custom Domain to Nextcloud Trusted Domains

```bash
sudo nano /var/www/nextcloud/config/config.php
```

Find `trusted_domains` and make it look like this — add entries for `naspi`, your Tailscale FQDN, and your custom domain:

```php
'trusted_domains' =>
array (
  0 => 'YOUR_LOCAL_IP',
  1 => 'YOUR_TAILSCALE_IP',
  2 => 'naspi.local',
  3 => 'naspi',
  4 => 'naspi.YOUR_TAILSCALE_DOMAIN.ts.net',
  5 => 'YOUR_HOSTNAME.nas',
),
```

Save: `Ctrl+X` → `Y` → `Enter`

```bash
sudo systemctl restart apache2
```

### 15.3 — Open Firewall on Pi for DNS

```bash
sudo ufw allow 53/udp
sudo ufw allow 53/tcp
sudo ufw reload
```

### 15.4 — Enable Tailscale Subnet Routing (Access from Anywhere)

This makes your local IP reachable through Tailscale from anywhere:

```bash
echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.conf
echo 'net.ipv6.conf.all.forwarding = 1' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
sudo tailscale up --advertise-routes=192.168.0.0/24 --accept-routes
```

> Run the `tailscale up` command again until you see NO warnings.

Then approve in Tailscale admin:
- Go to: https://login.tailscale.com/admin/machines
- Find `naspi` → click three dots `...` → Edit route settings
- Tick the checkbox next to `192.168.0.0/24` → Save

> ⚠️ Replace `192.168.0.0/24` with your actual home network subnet if it is different.

### 15.5 — Set Up Tailscale DNS (Automatic for All Tailscale Devices)

This makes the custom domain work automatically on every device with Tailscale ON.

- Go to: https://login.tailscale.com/admin/dns
- Nameservers section → Add nameserver → Custom → enter: `YOUR_TAILSCALE_IP`
- Tick **Restrict to domain** → type: `YOUR_HOSTNAME.nas` → Save

### 15.6 — Set DNS on Router and All Devices

This tells every device where your custom domain is. Choose Option A if your router supports custom DNS, otherwise use Option B.

**Option A — Set DNS in Router (Best — Covers All Home WiFi Devices Automatically)**

Log into your router and find the DNS setting under LAN, DHCP Settings, or Advanced. Set:
- Primary DNS: `YOUR_LOCAL_IP`
- Secondary DNS: `8.8.8.8`
- Save and apply

| Router Brand | Where to Find DNS Setting |
|---|---|
| TP-Link | Advanced → Network → LAN → DHCP Server → Primary DNS |
| ASUS | LAN → DHCP Server → DNS Server 1 |
| Netgear | Advanced → Setup → Internet Setup → Domain Name Server (DNS) Address |
| Linksys | Connectivity → Local Network → DHCP Reservations → Static DNS |
| Fritzbox | Home Network → Network → DNS Rebind Protection → Local DNS |

> ⚠️ Some routers (e.g. Tele2 FAST3890) do not have a DNS setting — use Option B instead.

**Option B — Set DNS Manually on Each Device**

> ⚠️ **DNS order is CRITICAL.** Always put `YOUR_LOCAL_IP` FIRST. If `8.8.8.8` is first, Google says the domain does not exist and your device never asks the Pi.

**MacBook — Permanent Fix (Resolver File)**

The simple DNS setting in System Settings gets overridden by macOS after sleep, WiFi reconnect, or Tailscale toggle. The permanent fix is a resolver file — one-time setup that survives everything.

Step 1 — Set DNS in System Settings:
- System Settings → WiFi → click WiFi name → Details → DNS tab
- Remove all entries with `−` button
- Add `YOUR_LOCAL_IP` (FIRST) → Add `8.8.8.8` (SECOND) → OK → Apply
- Run: `sudo tailscale up --accept-routes`

Step 2 — Create permanent resolver file (open Terminal):
```bash
sudo mkdir -p /etc/resolver
sudo nano /etc/resolver/nas
```

Paste exactly this — replace `YOUR_LOCAL_IP` and `YOUR_TAILSCALE_IP` with your real values:
```
nameserver YOUR_LOCAL_IP
nameserver YOUR_TAILSCALE_IP
```

Save: `Ctrl+X` → `Y` → `Enter`

Step 3 — Flush DNS cache:
```bash
sudo dscacheutil -flushcache
sudo killall -HUP mDNSResponder
```

Step 4 — Verify it is working:
```bash
scutil --dns | grep -A3 "nas"
```

✅ This resolver file tells macOS at system level: anything ending in `.nas` always goes to Pi first. Survives sleep, wake, Tailscale ON/OFF, WiFi reconnect, and reboots permanently.

**iPhone — Permanent Fix (3 DNS Servers in WiFi Settings)**

The manual WiFi DNS setting on iPhone is permanent — it never resets unless you delete and rejoin the WiFi network. Use 3 servers so the domain works at home AND outside:

- Settings → WiFi → tap ⓘ next to your WiFi name
- Tap Configure DNS → tap Manual
- Tap `−` to remove ALL existing entries
- Tap Add Server → type: `YOUR_LOCAL_IP` ← FIRST (Pi at home)
- Tap Add Server → type: `YOUR_TAILSCALE_IP` ← SECOND (Pi via Tailscale)
- Tap Add Server → type: `8.8.8.8` ← THIRD (Google backup)
- Tap Save → turn WiFi OFF then back ON to apply
- Tailscale app → tap account name → Settings → turn ON **Use Tailscale subnets**

✅ iPhone tries each server in order. Local IP answers at home. Tailscale IP answers when outside. Google handles all normal internet.

**Windows — Permanent Fix (Hosts File)**

Open Notepad as Administrator → File → Open → go to `C:\Windows\System32\drivers\etc\hosts` → change file type to All Files → scroll to the bottom → add this line:

```
YOUR_LOCAL_IP YOUR_HOSTNAME.nas
```

Save with `Ctrl+S`. Then open PowerShell as Administrator and run:
```powershell
tailscale up --accept-routes
```

✅ The hosts file is permanent — survives reboots and Windows updates forever.

**Android — Permanent Fix (2 DNS Servers)**

Settings → WiFi → long press your WiFi name → Modify network → Advanced options → IP settings: Static → set:
- DNS 1: `YOUR_LOCAL_IP` ← Pi at home
- DNS 2: `YOUR_TAILSCALE_IP` ← Pi via Tailscale outside

Tap Save. Then in Tailscale app → Settings → turn ON **Use Tailscale subnets**.

> 💡 Note: Android only has 2 DNS fields. If the Pi is off, normal internet (Google, YouTube etc.) will not work on Android until Pi comes back on — this is an Android limitation.

### 15.7 — Troubleshooting Custom Domain

| Problem | Fix |
|---|---|
| Custom domain disconnects on MacBook after sleep or Tailscale toggle | Create the permanent resolver file (see MacBook section above) — the only real fix that survives everything |
| Domain not opening on MacBook right now | Run: `sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder` |
| Works Tailscale OFF but not Tailscale ON | Check dnsmasq.conf on Pi — `listen-address` must have BOTH IPs: `YOUR_LOCAL_IP,YOUR_TAILSCALE_IP`. Then: `sudo systemctl restart dnsmasq` |
| Works Tailscale ON but not Tailscale OFF | DNS order wrong — put `YOUR_LOCAL_IP` FIRST and `8.8.8.8` SECOND in DNS settings |
| Samba via custom domain slow or sometimes fails | Add to smb.conf inside `[global]`: `dns proxy = no` and `name resolve order = host bcast`. Then: `sudo systemctl restart smbd`. Also add drive to Login Items: System Settings → General → Login Items → `+` → select mounted drive |
| Test if DNS is working | Run: `nslookup YOUR_HOSTNAME.nas YOUR_LOCAL_IP` — should show: Name: `YOUR_HOSTNAME.nas` and Address: `YOUR_LOCAL_IP` |
| Check dnsmasq is running on Pi | `sudo systemctl status dnsmasq` — look for: `active (running)` |
| Verify resolver file (MacBook) | `scutil --dns \| grep -A3 "nas"` |

> 💡 After any change to `/etc/dnsmasq.conf` on Pi always run: `sudo systemctl restart dnsmasq`

> 💡 After any DNS settings change on MacBook always run: `sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder`

---

## Skills Demonstrated

- **Linux System Administration** — Raspberry Pi OS, systemd service management, cron scheduling, UFW firewall, fstab configuration, persistent logging
- **Self-hosted Cloud Infrastructure** — Nextcloud deployment, Apache web server, PHP 8.3 tuning, MariaDB database administration, Redis caching
- **Network Configuration** — VPN setup with Tailscale/WireGuard, Samba SMB protocol, DHCP reservation, WiFi-only headless server setup
- **Security Implementation** — Firewall rules, zero-trust VPN tunneling, Redis file locking, automatic unattended security updates
- **Automation and Scripting** — Bash scripting, cron job scheduling, background process management, log rotation
- **Storage Management** — HDD formatting, UUID-based persistent mounting, Linux bind mounts, SMART health monitoring with smartmontools
- **Remote Access and Administration** — SSH, Tailscale VPN, complete headless server management from MacBook, iPhone, Windows, and Android
- **Cross-platform Compatibility** — macOS Tahoe, iOS Files app, Android, Windows SMB client configuration — all working simultaneously
- **Cloud Integration** — Google Drive migration via rclone with background transfer, automatic resume capability, nightly sync automation
- **Real-world Troubleshooting** — All errors encountered during setup documented with root cause analysis and tested fixes
- **Technical Documentation** — Complete step-by-step guide with commands, explanations, warnings, and reference tables for all 14 parts

---

## Author

**Md Motaher Hossain Bhuiyan**

Self-hosted NAS infrastructure — fully designed, built, configured, automated, and documented from scratch.
Real-world production setup in Sweden — every error encountered during setup is solved and documented.
