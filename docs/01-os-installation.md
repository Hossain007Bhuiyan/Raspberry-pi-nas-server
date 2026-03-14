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


## 1.8 — Set Custom Local Hostname (Access by Name Instead of IP)

Instead of typing `http://YOUR_LOCAL_IP/nextcloud` you can use a friendly
name like `http://YOUR_NAS_NAME.nas/nextcloud` from all devices on your
home network. Same applies to Samba — `smb://YOUR_NAS_NAME.nas` instead
of `smb://YOUR_LOCAL_IP`.

> **INFO:** This only works on your home network. When outside home,
> always use Tailscale with your Tailscale IP as normal. Global access
> is not affected by this setup at all.

There are two methods — **try Method 1 first**. Only do Method 2 if your
router does not have a local DNS option.

---

### Method 1 — Router DNS (Recommended — works for ALL devices automatically)

Configure once in the router and every device on your WiFi resolves the
name automatically — no per-device setup needed at all.

- Open your router admin page in a browser
- Look for one of these sections (name varies by router brand):
  - **Local DNS Records**
  - **DNS Hostnames**
  - **Custom DNS Entries**
  - **Static DNS**
  - **Host Records**

⚠️ Not all routers support this. If your router was provided directly
by your internet provider (ISP), it is likely locked down — meaning
the ISP restricts access to advanced settings and local DNS options
are not available to you. This is common with broadband providers who
supply their own branded router. If you cannot find any local DNS or
hostname option in your router admin page — use Method 2.

Add a new entry:

| Field | Value to enter |
|---|---|
| Hostname / Name | `YOUR_NAS_NAME.nas` |
| IP Address | `YOUR_LOCAL_IP` |

- Save and apply settings

**Test it — open MacBook Terminal:**
```bash
ping YOUR_NAS_NAME.nas
```

If you see replies — it is working. ✅

You can now use `http://YOUR_NAS_NAME.nas/nextcloud` in any browser and
`smb://YOUR_NAS_NAME.nas` in Finder — on every device on your home WiFi
without any further setup.

---

### Method 2 — Manual setup per device (if router has no DNS option)

Do this on each device separately. These steps only affect that
specific device — other devices still need their own setup.

---

#### MacBook (macOS)

Open Terminal and edit the hosts file:
```bash
sudo nano /etc/hosts
```

Add this line at the very bottom of the file:
```
YOUR_LOCAL_IP    YOUR_NAS_NAME.nas
```

Save: `Ctrl+X` → `Y` → `Enter`

Now flush the DNS cache so macOS picks up the change immediately:
```bash
sudo dscacheutil -flushcache
sudo killall -HUP mDNSResponder
```

Test it works:
```bash
ping YOUR_NAS_NAME.nas
```

If you see replies — done. ✅

You can now open Safari and go to `http://YOUR_NAS_NAME.nas/nextcloud`
and use `smb://YOUR_NAS_NAME.nas` in Finder on this MacBook.

---

#### iPhone (iOS)

iPhones do not allow editing a hosts file directly. The way to set a
custom hostname manually on iPhone is to point the iPhone's DNS to the
Pi itself — and run a lightweight DNS service on the Pi that answers
for your custom name.

**Step 1 — Install dnsmasq on the Pi (SSH into Pi first):**
```bash
sudo apt install dnsmasq -y
```

**Step 2 — Add your custom hostname to dnsmasq:**
```bash
echo "address=/YOUR_NAS_NAME.nas/YOUR_LOCAL_IP" | sudo tee /etc/dnsmasq.d/nas-hostname.conf
```

**Step 3 — Restart dnsmasq:**
```bash
sudo systemctl restart dnsmasq
sudo systemctl enable dnsmasq
```

Verify it is running:
```bash
sudo systemctl status dnsmasq
```

Look for: `active (running)` ✅

**Step 4 — Point iPhone DNS to the Pi:**
- On iPhone go to: **Settings → WiFi**
- Tap the `ⓘ` icon next to your home WiFi network name
- Scroll down → tap **Configure DNS**
- Change from **Automatic** to **Manual**
- Tap **Add Server** → type: `YOUR_LOCAL_IP`
- Delete the existing DNS servers (the ones that were already there)
- Tap **Save** (top right)

**Step 5 — Test on iPhone:**
- Open Safari → type: `http://YOUR_NAS_NAME.nas/nextcloud`
- You should see the Nextcloud login page ✅

> ⚠️ This DNS setting only works on your home WiFi. When iPhone switches
> to mobile data or another WiFi network, it reverts to the default DNS
> automatically. Your NAS is still accessible from anywhere using the
> Tailscale IP — this hostname setup is for home convenience only.

> ⚠️ If you ever reset your iPhone network settings, you will need to
> redo Step 4 only — the Pi side (Steps 1–3) is permanent and does not
> need to be repeated.

---

[← SSH Access](00-ssh-access.md) | [Back to README](../README.md) | [Next: HDD Setup →](02-hdd-setup.md)
