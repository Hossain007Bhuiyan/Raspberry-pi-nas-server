# Part 1 — Install Raspberry Pi OS (Headless Setup)

> **INFO:** Headless setup means no monitor, no keyboard — the Pi runs without any display. Everything is configured inside Raspberry Pi Imager BEFORE the first boot. This setup was done using WiFi. If you prefer, you can also plug in an Ethernet cable and the Pi will use it automatically — no extra configuration needed.

---

## 1.1 — Download and open Raspberry Pi Imager

**On MacBook:**
- Go to: https://www.raspberrypi.com/software/
- Click Download for macOS → open `.dmg` → drag to Applications → open

**On Windows:**
- Go to: https://www.raspberrypi.com/software/
- Click Download for Windows → open the `.exe` installer → click Install → open Raspberry Pi Imager

---

## 1.2 — Configure ALL settings before writing

- Choose Device: **Raspberry Pi 4**
- Choose OS: **Raspberry Pi OS (other) → Raspberry Pi OS Lite (64-bit)** — Bookworm version
- Choose Storage: your 128GB microSD card
- Click Next → **Edit Settings** — fill in every field:

| Setting | Value to enter |
|---|---|
| Hostname | `naspi` *(this is the name used in this guide — you can choose any name you like)* |
| Username | `YOUR_SSH_USERNAME` |
| Password | `YOUR_SSH_PASSWORD` |
| Configure WiFi | YES — enter your WiFi name exactly (case-sensitive) |
| WiFi Password | Your exact router WiFi password |
| WiFi Country | Your country code — e.g. `SE` for Sweden — **CRITICAL** |
| Enable SSH | YES — Use password authentication |
| Raspberry Pi Connect | OFF |
| Timezone | Your timezone — e.g. `Europe/Stockholm` |
| Keyboard | Your keyboard layout — e.g. `se` or `gb` |

> ⚠️ **WiFi Country is absolutely critical.** Without it the Pi's WiFi hardware is disabled by law. You will have no connection at all.
>
> **Using Ethernet instead of WiFi?** You can skip the WiFi name and password fields entirely. Simply plug an Ethernet cable into the Pi before powering it on — it will get an IP address automatically from your router. No extra configuration needed.

Click Save → Yes → confirm erase → Yes
Wait 5–15 minutes — do NOT remove card until Imager says **Write Successful**

**Eject microSD on MacBook:**
Finder → right-click card → Eject

**Eject microSD on Windows:**
System tray (bottom right) → Safely Remove Hardware icon → click Eject → then remove card

---

## 1.3 — First Boot

- Insert microSD into Pi (underside slot — gold contacts face the board — clicks into place)
- Do NOT connect HDDs yet
- Connect USB-C power — red LED solid, green LED flashing = booting
- Wait **2 full minutes** for first boot

---

## 1.4 — Find Pi's IP address

**Method 1 — ping (MacBook Terminal or Windows PowerShell):**
```bash
ping naspi.local
```
Example output: `PING naspi.local (192.168.X.XX)` — the number in brackets is the IP.

**Method 2 — router admin page (works from any device):**
Open your router's IP in browser → Connected Devices or DHCP Clients → find `naspi`

---

## 1.5 — SSH into Pi for the first time

```bash
ssh YOUR_SSH_USERNAME@YOUR_LOCAL_IP
```

Type `yes` → Enter password.
You are in when you see: `YOUR_SSH_USERNAME@naspi:~ $`

---

## 1.6 — Set static IP (DHCP reservation in router)

- Log into router admin page
- Find **DHCP Reservation** or **Address Reservation**
- Find `naspi` → Reserve this IP → Save

✅ Pi's IP is now permanently fixed. It will never change after reboots.

---

## 1.7 — Update system

```bash
sudo apt update
sudo apt upgrade -y
sudo reboot
```

Wait 1 minute after reboot, then SSH back in.

---

[← SSH Access](00-ssh-access.md) | [Back to README](../README.md) | [Next: HDD Setup →](02-hdd-setup.md)
