# Part 0 — SSH Access: How to Control Your Pi from Any Device

SSH is how you type commands on the Pi from another device. This is your only way to manage the Pi since it has no monitor or keyboard. You need this for all maintenance and troubleshooting.

---

## 0.1 — Connect from MacBook (Terminal)

Open Terminal: Applications → Utilities → Terminal

**When on HOME WiFi:**
```bash
ssh YOUR_SSH_USERNAME@YOUR_LOCAL_IP
```

**When OUTSIDE HOME (Tailscale must be ON on MacBook):**
```bash
ssh YOUR_SSH_USERNAME@YOUR_TAILSCALE_IP
```

First time only: type `yes` when asked about fingerprint → Enter password.

You are now inside your Pi when you see:
```
YOUR_SSH_USERNAME@naspi:~ $
```

---

## 0.2 — Connect from iPhone

Install the app:
- Open App Store on iPhone → search: **Termius** → install (by Termius, free)

**Set up connection — Home WiFi:**
- Open Termius → tap `+` (top right) → New Host
- Label: `NAS Pi Home`
- Hostname: `YOUR_LOCAL_IP`
- Username: `YOUR_SSH_USERNAME`
- Password: `YOUR_SSH_PASSWORD`
- Tap Save → tap the host to connect
- First time only: tap Continue when asked about fingerprint
- You are in when you see: `YOUR_SSH_USERNAME@naspi:~ $`

**Set up connection — Global access (from anywhere):**
- Make sure Tailscale is ON on iPhone first
- In Termius → tap `+` → New Host
- Label: `NAS Pi Global`
- Hostname: `YOUR_TAILSCALE_IP`
- Username: `YOUR_SSH_USERNAME`
- Password: `YOUR_SSH_PASSWORD`
- Tap Save → tap to connect

---

## 0.3 — Connect from Android

Install the app:
- Open Play Store → search: **JuiceSSH** → install (by Sonelli, free)

**Set up connection — Home WiFi:**
- Open JuiceSSH → Connections tab → tap `+` (bottom right)
- Nickname: `NAS Pi Home`
- Type: SSH
- Address: `YOUR_LOCAL_IP`
- Tap the identity field → New Identity
- Nickname: `NAS`
- Username: `YOUR_SSH_USERNAME`
- Password: `YOUR_SSH_PASSWORD` → tick → Save
- Back to connection → tap Save → tap the connection to connect
- First time: tap Accept when asked about fingerprint
- You are in when you see: `YOUR_SSH_USERNAME@naspi:~ $`

**Set up connection — Global access (from anywhere):**
- Make sure Tailscale is ON on Android first
- Create another connection with same settings but Address: `YOUR_TAILSCALE_IP`
- Nickname: `NAS Pi Global` → Save

---

## 0.4 — Connect from Windows

Windows 10 and 11 have SSH built in — no app needed.

**Home WiFi:**
- Press Windows key → search: PowerShell → open it
- Type this command and press Enter:
```powershell
ssh YOUR_SSH_USERNAME@YOUR_LOCAL_IP
```
- First time only: type `yes` → press Enter when asked about fingerprint
- Enter password
- You are in when you see: `YOUR_SSH_USERNAME@naspi:~ $`

**Global access (from anywhere):**
- Make sure Tailscale is ON — check system tray (bottom right)
- Open PowerShell and type:
```powershell
ssh YOUR_SSH_USERNAME@YOUR_TAILSCALE_IP
```

---

## 0.5 — Check if Pi is online before connecting

```bash
ping naspi.local
```

If you see replies — Pi is online. Press `Ctrl+C` to stop.

If ping fails: open router admin at your router's IP → Connected Devices → find naspi → use that IP.

---

## 0.6 — Essential Commands Inside the Pi

| Command | What it does |
|---|---|
| `df -h \| grep /mnt` | Check how full your HDDs are |
| `lsblk` | See all connected drives and partitions |
| `sudo systemctl status apache2` | Check if Nextcloud is running |
| `sudo systemctl status smbd` | Check if Samba is running |
| `sudo systemctl status redis-server` | Check if Redis cache is running |
| `tailscale status` | Check Tailscale VPN and see connected devices |
| `tailscale ip -4` | Show Pi's Tailscale IP |
| `sudo systemctl restart apache2` | Restart Nextcloud web server |
| `sudo systemctl restart smbd` | Restart Samba |
| `sudo apt update && sudo apt upgrade -y` | Update all software — do this monthly |
| `sudo reboot` | Restart Pi safely |
| `sudo shutdown -h now` | Shut Pi down safely |
| `exit` | Leave the SSH session |

---

[← Back to README](../README.md) | [Next: OS Installation →](01-os-installation.md)
