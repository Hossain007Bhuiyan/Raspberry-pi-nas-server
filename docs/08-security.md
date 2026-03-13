# Part 8 — Security Setup

---

## 8.1 — Install and configure UFW firewall

> ⚠️ **Add SSH rule FIRST before enabling.** If you enable UFW without the SSH rule, you will be permanently locked out of your Pi remotely.

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

> Note: Replace `192.168.0.0/24` with your actual home network range if different.

---

## 8.2 — Enable automatic security updates

```bash
sudo apt install unattended-upgrades -y
sudo dpkg-reconfigure --priority=low unattended-upgrades
```

Select **YES** when prompted.

---

## 8.3 — Monthly manual update (do once a week or month)

```bash
sudo apt update && sudo apt upgrade -y
```

---

## 8.4 — Enable Automatic Weekly Updates if you don't want manual update

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

[← File Transfer](07-file-transfer.md) | [Back to README](../README.md) | [Next: Troubleshooting →](09-troubleshooting.md)
