# Part 11 — Shutdown, Restart and Daily Use

> **Why shut down when not using it?** Saves electricity. Reduces HDD wear — HDDs have a limited number of running hours. Extends the life of your Raspberry Pi and drives significantly.

---

## 11.1 — How to Shut Down Safely (ALWAYS follow this order)

> ⚠️ NEVER just pull the power cable or switch off the dock while Pi is running. This can corrupt files on your HDDs and damage the microSD card.

**Step 1 — SSH into your Pi from any device:**
```bash
ssh YOUR_SSH_USERNAME@YOUR_LOCAL_IP
```
iPhone: open Termius → tap NAS Pi Home connection
Android: open JuiceSSH → tap NAS Pi Home connection
Windows: open PowerShell → type: `ssh YOUR_SSH_USERNAME@YOUR_LOCAL_IP`

**Step 2 — Run the shutdown command (same for all devices):**
```bash
sudo shutdown -h now
```

**Step 3 — Watch the Pi LEDs:**
- Green LED will flash a few times then go **OFF completely**
- Red LED stays ON (this is normal — it just means power is still connected)
- Wait **30 full seconds** after green LED goes off

**Step 4 — Turn off docking station:**
- Flip the power switch on the BACK of the RSHTECH dock to OFF
- Both HDD lights on the dock will turn off

✅ Shutdown is now complete. Safe to leave it off as long as you want — hours, days, weeks.

| Action | Safe? |
|---|---|
| `sudo shutdown -h now` → wait for LED → then turn off dock | ✅ YES — always do this |
| Pull Pi power cable while running | ❌ NO — can corrupt files |
| Turn off dock switch while Pi is running | ❌ NO — can corrupt drives |
| Close MacBook/Terminal during normal use | ✅ YES — Pi keeps running |
| Close MacBook/Terminal after shutdown command sent | ✅ YES — command already sent to Pi |

---

## 11.2 — How to Power On (ALWAYS follow this order)

**Step 1 — Turn on docking station FIRST:**
- Flip the power switch on the back of the RSHTECH dock to ON
- HDD lights on dock turn on — drives are spinning up
- Wait **10 seconds** for drives to fully spin up

**Step 2 — Connect Pi power:**
- Connect USB-C power cable to Raspberry Pi
- Red LED turns on immediately
- Green LED starts flashing — Pi is booting

**Step 3 — Wait for Pi to fully boot:**
- Wait **60 to 90 seconds** — do not try to connect before this
- Green LED settles to occasional flashes = Pi is ready

**Step 4 — Verify drives are mounted (optional but recommended):**
```bash
ssh YOUR_SSH_USERNAME@YOUR_LOCAL_IP
df -h | grep /mnt
```

Expected output — both drives should appear:

| What you see | What it means |
|---|---|
| `/dev/sda1` ... `/mnt/drive4tb` | 4TB HDD mounted correctly |
| `/dev/sdb1` ... `/mnt/650GB` | 650GB HDD mounted correctly |

✅ Both drives appear — everything is running perfectly. Ready to use.

---

## 11.3 — Everything Starts Automatically — No Commands Needed

When Pi boots, ALL services start by themselves automatically. You do not need to type any commands.

| Service | Status after boot |
|---|---|
| Drive mounts (4TB and 650GB) | Auto-mounted via fstab |
| Nextcloud (Apache web server) | Auto-starts — accessible immediately |
| Samba file sharing | Auto-starts — Finder/Files app connects instantly |
| Redis cache | Auto-starts — Nextcloud performs at full speed |
| Tailscale VPN | Auto-starts — global access available immediately |
| Background file scan (cron) | Auto-runs every 5 minutes |

---

## 11.4 — Access Your Data After Boot

Wait 60–90 seconds after powering on, then access your files any of these ways:

| Device and Method | What to do |
|---|---|
| MacBook — Nextcloud browser | Open Safari → `http://YOUR_LOCAL_IP/nextcloud` → login |
| MacBook — Finder (Samba) | Finder → `Command+K` → `smb://YOUR_LOCAL_IP` → login |
| iPhone — Nextcloud app | Just open the app — it reconnects automatically |
| iPhone — Files app (Samba) | Files → Browse → Shared → tap your NAS share |
| Android — Nextcloud app | Open app — reconnects automatically |
| Windows — File Explorer | Open Z: drive (mapped) — reconnects automatically |
| Global from anywhere | Turn Tailscale ON on your device → use `YOUR_TAILSCALE_IP` instead of `YOUR_LOCAL_IP` |

---

## 11.5 — Quick Shutdown and Startup Summary Card

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

---

## 11.6 — Auto-Restart Services if They Crash

These commands make Nextcloud, Samba and Redis restart automatically within 10 seconds if they crash — without needing to reboot the whole Pi. This is a one-time setup — works permanently after every reboot.

**Nextcloud (Apache):**
```bash
sudo nano /etc/systemd/system/apache2.service.d/override.conf
```
Paste this inside:
```ini
[Service]
Restart=always
RestartSec=10
```
Save: `Ctrl+X` → `Y` → `Enter`

**Samba:**
```bash
sudo nano /etc/systemd/system/smbd.service.d/override.conf
```
Paste this inside:
```ini
[Service]
Restart=always
RestartSec=10
```
Save: `Ctrl+X` → `Y` → `Enter`

**Redis:**
```bash
sudo nano /etc/systemd/system/redis-server.service.d/override.conf
```
Paste this inside:
```ini
[Service]
Restart=always
RestartSec=10
```
Save: `Ctrl+X` → `Y` → `Enter`

Apply all changes — run once:
```bash
sudo systemctl daemon-reload
sudo systemctl restart apache2
sudo systemctl restart smbd
sudo systemctl restart redis-server
```

✅ Done — if Nextcloud, Samba or Redis ever crashes, it restarts automatically within 10 seconds.

---

[← Quick Reference](10-quick-reference.md) | [Back to README](../README.md) | [Next: Crash Troubleshooting →](12-crash-troubleshooting.md)
