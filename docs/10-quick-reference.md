# Part 10 — Complete Quick Reference Card

---

## 10.1 — All Access Addresses

| Device and Service | Home WiFi Address | Global Address (Tailscale ON) | Custom Domain (anywhere) |
|---|---|---|---|
| Any browser — Nextcloud | `http://YOUR_LOCAL_IP/nextcloud` | `http://YOUR_TAILSCALE_IP/nextcloud` | `http://YOUR_CUSTOM_DOMAIN/nextcloud` |
| MacBook Finder — Samba | `smb://YOUR_LOCAL_IP` | `smb://YOUR_TAILSCALE_IP` | `smb://YOUR_CUSTOM_DOMAIN` |
| iPhone Files app — Samba | `smb://YOUR_LOCAL_IP` | `smb://YOUR_TAILSCALE_IP` | `smb://YOUR_CUSTOM_DOMAIN` |
| Android CX File Explorer | `YOUR_LOCAL_IP` (server field) | `YOUR_TAILSCALE_IP` (server field) | `YOUR_CUSTOM_DOMAIN` (server field) |
| Windows File Explorer | `\\YOUR_LOCAL_IP\4TB` | `\\YOUR_TAILSCALE_IP\4TB` | `\\YOUR_CUSTOM_DOMAIN\4TB` |
| SSH from MacBook / Terminal | `ssh YOUR_SSH_USERNAME@YOUR_LOCAL_IP` | `ssh YOUR_SSH_USERNAME@YOUR_TAILSCALE_IP` | `ssh YOUR_SSH_USERNAME@YOUR_CUSTOM_DOMAIN` |
| SSH from iPhone (Termius) | Host: `YOUR_LOCAL_IP` | Host: `YOUR_TAILSCALE_IP` | Host: `YOUR_CUSTOM_DOMAIN` |

> 💡 Custom domain requires Part 15 setup. IP addresses always work as backup even without it.

---

## 10.2 — All Usernames and Passwords

> ⚠️ Fill in your own values. Never share this publicly with real passwords.

| Service | Username / Password |
|---|---|
| Pi SSH login (Terminal) | `YOUR_SSH_USERNAME` / `YOUR_SSH_PASSWORD` |
| Samba file sharing (all devices) | `YOUR_SAMBA_USERNAME` / `YOUR_SAMBA_PASSWORD` |
| Nextcloud web and apps | `YOUR_NEXTCLOUD_ADMIN` / `YOUR_NEXTCLOUD_PASSWORD` |
| MariaDB database root | `root` / `YOUR_DB_ROOT_PASSWORD` |
| Nextcloud database user | `YOUR_DB_USERNAME` / `YOUR_DB_PASSWORD` |
| Router admin page | Check router label for IP and password |

---

## 10.3 — Important File and Folder Paths

| What | Full path |
|---|---|
| 4TB HDD mount point | `/mnt/drive4tb` |
| 650GB HDD mount point | `/mnt/650GB` |
| Nextcloud data (system folder) | `/mnt/drive4tb/nextcloud-data` |
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
| dnsmasq config | `/etc/dnsmasq.conf` |
| macOS resolver file | `/etc/resolver/YOUR_CUSTOM_DOMAIN_SUFFIX` |

---

## 10.4 — All Essential Terminal Commands

| Is Nextcloud web server running? | `sudo systemctl status apache2` |
| Is Samba running? | `sudo systemctl status smbd` |
| Is Redis cache running? | `sudo systemctl status redis-server` |
| Is Tailscale connected? | `tailscale status` |
| What is my Tailscale IP? | `tailscale ip -4` |
| Is dnsmasq (custom domain DNS) running? | `sudo systemctl status dnsmasq` |
| Restart Nextcloud (Apache) | `sudo systemctl restart apache2` |
| Restart Samba | `sudo systemctl restart smbd` |
| Restart Redis | `sudo systemctl restart redis-server` |
| Restart dnsmasq | `sudo systemctl restart dnsmasq` |
| Rescan files for Nextcloud manually | `sudo -u www-data php /var/www/nextcloud/occ files:scan --all` |
| Start a background file copy | `sudo nohup rsync -av --chown=www-data:www-data /mnt/SOURCE/ /mnt/drive4tb/nextcloud-data/YOUR_NEXTCLOUD_ADMIN/files/4TB/DESTINATION/ > /home/YOUR_SSH_USERNAME/copy-progress.log 2>&1 &` |
| Check copy progress | `tail -f /home/YOUR_SSH_USERNAME/copy-progress.log` |
| Is rsync copy still running? | `ps aux \| grep rsync` |
| Update all software (do monthly) | `sudo apt update && sudo apt upgrade -y` |
| Reboot Pi safely | `sudo reboot` |
| Shut Pi down safely | `sudo shutdown -h now` |
| Edit Nextcloud config | `sudo nano /var/www/nextcloud/config/config.php` |
| Edit Samba config | `sudo nano /etc/samba/smb.conf` |
| Edit drive mount config | `sudo nano /etc/fstab` |
| Edit dnsmasq config | `sudo nano /etc/dnsmasq.conf` |
| Test Samba config for errors | `testparm` |
| Check firewall rules | `sudo ufw status verbose` |
| Test custom domain DNS from MacBook | `nslookup YOUR_CUSTOM_DOMAIN YOUR_LOCAL_IP` |
| Flush DNS cache on MacBook | `sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder` |

---

[← Troubleshooting](09-troubleshooting.md) | [Back to README](../README.md) | [Next: Daily Use →](11-daily-use.md)
