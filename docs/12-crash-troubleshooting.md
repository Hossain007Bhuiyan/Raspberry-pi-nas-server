# Part 12 — Troubleshooting Unexpected Shutdowns

Most common causes of unexpected shutdown: Overheating, Undervoltage (weak USB-C power supply), Heavy workload (long rsync or rclone transfers using too much memory), or a random kernel crash. Follow the steps below to identify and fix the exact cause.

---

## 12.1 — Enable Persistent Logs (do this first — one time only)

By default, Raspberry Pi OS does not save logs after reboot. This means after an unexpected shutdown, all evidence of what happened is deleted. Enable persistent logs so crash information survives reboots.

Fix the journald config to save logs permanently:
```bash
sudo sed -i 's/#Storage=persistent/Storage=persistent/' /etc/systemd/journald.conf
```

Verify the change was applied correctly:
```bash
grep Storage /etc/systemd/journald.conf
```

You should see: `Storage=persistent` (without the `#` symbol)

Create the journal folder and restart the journal service:
```bash
sudo mkdir -p /var/log/journal/$(cat /etc/machine-id)
sudo systemctl restart systemd-journald
```

Reboot Pi to activate persistent logging:
```bash
sudo reboot
```

After reboot — verify logs folder exists:
```bash
ls /var/log/journal/
```

✅ You should see a folder with a long ID. Persistent logs are now enabled permanently.

---

## 12.2 — Check Temperature

Raspberry Pi 4 safe operating temperature is 40°C to 70°C. Above 80°C it throttles and may shut down to protect itself.

```bash
vcgencmd measure_temp
```

| Temperature shown | What it means and what to do |
|---|---|
| 40°C – 60°C | ✅ Perfect — normal operating temperature |
| 60°C – 70°C | Warm but acceptable — ensure open airflow around Pi |
| 70°C – 80°C | Hot — add heatsink immediately |
| 80°C+ | **CRITICAL** — Pi will throttle and shut down — add heatsink and fan urgently |

If overheating — solutions:
- Add a heatsink on the Pi CPU chip — small silver or copper stick-on pad, costs around 2–5 EUR
- Add a small 5V fan on top of the heatsink
- Make sure Pi is NOT enclosed in a closed box — it needs open airflow around it
- Do not place Pi near other heat sources like routers or power adapters

---

## 12.3 — Check Power Supply (Undervoltage)

Raspberry Pi 4 requires exactly 5V 3A USB-C power. A phone charger or cheap cable causes undervoltage which makes Pi unstable and causes random shutdowns.

```bash
vcgencmd get_throttled
```

| Result shown | What it means |
|---|---|
| `throttled=0x0` | ✅ Power supply is perfect — no issues at all |
| `throttled=0x50005` | ⚠️ Undervoltage detected — replace power supply immediately |
| `throttled=0x80008` | ⚠️ Overheating detected — add heatsink and fan |
| `throttled=0x50050005` | ⚠️ Both undervoltage AND overheating — fix both issues |

If undervoltage detected — solution:
- Buy the official Raspberry Pi 4 USB-C Power Supply: 5.1V 3A
- Use a short thick USB-C cable — long thin cables cause voltage drop
- Never use a phone charger — they cannot provide stable 3A power continuously

---

## 12.4 — Read Crash Logs After Unexpected Shutdown

After enabling persistent logs in 12.1, you can see exactly what happened before the Pi shut down.

Run this after SSH-ing back in following any unexpected shutdown:
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

---

## 12.5 — Fix Locale Warnings

When SSHing into Pi you may see repeated warnings like: `setlocale: LC_CTYPE: cannot change locale (UTF-8)`. These are completely harmless and do not affect Nextcloud, Samba, or any other service. To fix them:

```bash
sudo locale-gen en_GB.UTF-8
sudo update-locale LANG=en_GB.UTF-8
sudo reboot
```

After reboot SSH back in — the locale warnings should be gone.

> **IMPORTANT:** If locale warnings still appear after reboot — ignore them completely. All NAS services work perfectly regardless.

---

## 12.6 — Verify All Services After Unexpected Shutdown

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

---

## 12.7 — All Diagnostic Commands Quick Reference

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

[← Daily Use](11-daily-use.md) | [Back to README](../README.md) | [Next: Google Drive Sync →](13-google-drive-sync.md)
