# Part 15 — Custom Domain: YOUR_CUSTOM_DOMAIN

> **One name for everything — works at home and anywhere in the world**

| Instead of this (old) | Use this (new) — works everywhere |
|---|---|
| `http://YOUR_LOCAL_IP/nextcloud` (home only) | `http://YOUR_CUSTOM_DOMAIN/nextcloud` |
| `http://YOUR_TAILSCALE_IP/nextcloud` (outside only) | `http://YOUR_CUSTOM_DOMAIN/nextcloud` |
| `smb://YOUR_LOCAL_IP` (home only) | `smb://YOUR_CUSTOM_DOMAIN` |
| `smb://YOUR_TAILSCALE_IP` (outside only) | `smb://YOUR_CUSTOM_DOMAIN` |
| `ssh YOUR_SSH_USERNAME@YOUR_LOCAL_IP` | `ssh YOUR_SSH_USERNAME@YOUR_CUSTOM_DOMAIN` |

> 💡 Old IP addresses still work as backup always. `YOUR_CUSTOM_DOMAIN` is added on top — nothing is removed or broken.

---

## 15.1 — Install DNS Server on Pi (dnsmasq)

SSH into Pi and run these commands one by one:
```bash
ssh YOUR_SSH_USERNAME@YOUR_LOCAL_IP
sudo apt install dnsmasq -y
sudo nano /etc/dnsmasq.conf
```

Scroll to the very bottom of the file and add exactly these 5 lines:
```
address=/YOUR_CUSTOM_DOMAIN/YOUR_LOCAL_IP
domain-needed
bogus-priv
listen-address=YOUR_LOCAL_IP,YOUR_TAILSCALE_IP
bind-interfaces
```

Save: `Ctrl+X` → `Y` → `Enter` then run:
```bash
sudo systemctl restart dnsmasq
sudo systemctl enable dnsmasq
```

> ⚠️ **CRITICAL:** `listen-address` must have BOTH IPs separated by a comma. Without `YOUR_TAILSCALE_IP`, your custom domain breaks when Tailscale is ON.

---

## 15.2 — Add Custom Domain to Nextcloud Trusted Domains

Still in Pi terminal, open Nextcloud config:
```bash
sudo nano /var/www/nextcloud/config/config.php
```

Find `trusted_domains` and make it look exactly like this:
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

> **Where to find `YOUR_TAILSCALE_MACHINE_FQDN`:** Go to https://login.tailscale.com/admin/machines → find your Pi → the full machine name shown there (e.g. `naspi.tail3195f2.ts.net`)

Save: `Ctrl+X` → `Y` → `Enter` then restart Nextcloud:
```bash
sudo systemctl restart apache2
```

---

## 15.3 — Open Firewall on Pi for DNS

Allow DNS traffic through the Pi firewall:
```bash
sudo ufw allow 53/udp
sudo ufw allow 53/tcp
sudo ufw reload
```

---

## 15.4 — Enable Tailscale Subnet Routing (Access from Anywhere)

This makes `YOUR_LOCAL_IP` reachable through Tailscale from anywhere. Run on Pi:
```bash
echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.conf
echo 'net.ipv6.conf.all.forwarding = 1' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
sudo tailscale up --advertise-routes=YOUR_HOME_NETWORK_RANGE --accept-routes
```

> Replace `YOUR_HOME_NETWORK_RANGE` with your actual home network range — e.g. `192.168.0.0/24`

Run the tailscale command again until you see NO warnings. Then approve in Tailscale website:
- Go to: https://login.tailscale.com/admin/machines
- Find your Pi → click three dots `...` → **Edit route settings**
- Tick the checkbox next to your network range → Save

---

## 15.5 — Set Up Tailscale DNS (Automatic for All Tailscale Devices)

This makes `YOUR_CUSTOM_DOMAIN` work automatically on every device with Tailscale ON.

- Go to: https://login.tailscale.com/admin/dns
- Nameservers section → **Add nameserver** → Custom → enter: `YOUR_TAILSCALE_IP`
- Tick **Restrict to domain** → type: `YOUR_CUSTOM_DOMAIN_SUFFIX` (e.g. `nas`)
- Save

---

## 15.6 — Set DNS on Router and All Devices

This tells every device where `YOUR_CUSTOM_DOMAIN` is. Choose **Option A** if your router supports DNS, otherwise use **Option B**.

---

### Option A — Set DNS in Router (Best — Covers All Home WiFi Devices Automatically)

Log into your router admin page and find the DNS setting under LAN, DHCP Settings, or Advanced. Set:
- **Primary DNS:** `YOUR_LOCAL_IP`
- **Secondary DNS:** `8.8.8.8`
- Save and apply

| Router Brand | Where to Find DNS Setting |
|---|---|
| TP-Link | Advanced → Network → LAN → DHCP Server → Primary DNS |
| ASUS | LAN → DHCP Server → DNS Server 1 |
| Netgear | Advanced → Setup → Internet Setup → Domain Name Server (DNS) Address |
| Linksys | Connectivity → Local Network → DHCP Reservations → Static DNS |
| Fritzbox | Home Network → Network → DNS Rebind Protection → Local DNS |

> ⚠️ Some routers (e.g. certain ISP-provided models) do not have a DNS setting available. If yours has no DNS option, use Option B below.

---

### Option B — Set DNS Manually on Each Device (When Router Has No DNS Setting)

> ⚠️ **DNS order is CRITICAL.** Always put `YOUR_LOCAL_IP` FIRST. If `8.8.8.8` is first, Google says `YOUR_CUSTOM_DOMAIN` does not exist and your device never asks the Pi.

---

#### MacBook — Permanent Fix (Resolver File)

The simple DNS setting in System Settings gets overridden by macOS after sleep, WiFi reconnect, or Tailscale toggle. The permanent fix is a resolver file — a one-time setup that survives everything.

**Step 1 — Set DNS in System Settings first:**
- System Settings → WiFi → click WiFi name → Details → DNS tab
- Remove all entries with `−` button
- Add `YOUR_LOCAL_IP` **(FIRST)** → Add `8.8.8.8` **(SECOND)** → OK → Apply
- Run:
```bash
sudo tailscale up --accept-routes
```

**Step 2 — Create permanent resolver file (open Terminal):**
```bash
sudo mkdir -p /etc/resolver
sudo nano /etc/resolver/YOUR_CUSTOM_DOMAIN_SUFFIX
```

Paste exactly this inside:
```
nameserver YOUR_LOCAL_IP
nameserver YOUR_TAILSCALE_IP
```

> Replace `YOUR_CUSTOM_DOMAIN_SUFFIX` with just the suffix part of your domain — e.g. if domain is `hossain.nas`, the file name is `nas`

Save: `Ctrl+X` → `Y` → `Enter`

**Step 3 — Flush DNS cache:**
```bash
sudo dscacheutil -flushcache
sudo killall -HUP mDNSResponder
```

**Step 4 — Verify it is working:**
```bash
scutil --dns | grep -A3 "YOUR_CUSTOM_DOMAIN_SUFFIX"
```

✅ This resolver file tells macOS at system level: anything ending in `.YOUR_CUSTOM_DOMAIN_SUFFIX` always goes to Pi first. Survives sleep, wake, Tailscale ON/OFF, WiFi reconnect, and reboots permanently.

---

#### iPhone — Permanent Fix (3 DNS Servers in WiFi Settings)

The manual WiFi DNS setting on iPhone is permanent — it never resets unless you delete and rejoin the WiFi network. Use 3 servers so `YOUR_CUSTOM_DOMAIN` works at home AND outside.

- Settings → WiFi → tap `ⓘ` next to your WiFi name
- Tap **Configure DNS** → tap **Manual**
- Tap `−` to remove ALL existing entries
- Tap **Add Server** → type: `YOUR_LOCAL_IP` ← **FIRST** (Pi at home)
- Tap **Add Server** → type: `YOUR_TAILSCALE_IP` ← **SECOND** (Pi via Tailscale)
- Tap **Add Server** → type: `8.8.8.8` ← **THIRD** (Google backup)
- Tap **Save**
- Turn WiFi OFF then back ON to apply
- Tailscale app → tap account name → Settings → turn ON **Use Tailscale subnets**

✅ iPhone tries each server in order. `YOUR_LOCAL_IP` answers at home. `YOUR_TAILSCALE_IP` answers when Tailscale is ON outside. `8.8.8.8` handles all normal internet as backup.

---

#### Windows — Permanent Fix (Hosts File)

Open Notepad as Administrator → File → Open → go to `C:\Windows\System32\drivers\etc\hosts` → change file type to **All Files** → scroll to bottom → add this line:
```
YOUR_LOCAL_IP    YOUR_CUSTOM_DOMAIN
```

Save: `Ctrl+S`. Then open PowerShell as Administrator and run:
```powershell
tailscale up --accept-routes
```

✅ Hosts file is permanent — survives reboots and Windows updates forever.

---

#### Android — Permanent Fix (Static DNS in WiFi Settings)

Settings → WiFi → long press WiFi name → **Modify network** → Advanced options → IP settings: **Static** → set:
- **DNS 1:** `YOUR_LOCAL_IP` ← Pi at home
- **DNS 2:** `YOUR_TAILSCALE_IP` ← Pi via Tailscale outside

Tap **Save**. Then in Tailscale app → Settings → turn ON **Use Tailscale subnets**.

✅ These settings are permanent per WiFi network — never reset unless you forget and rejoin.

> 💡 **Note:** Android only allows 2 DNS fields. If the Pi is off, normal internet (Google, YouTube etc.) will not work until the Pi comes back on. This is an Android limitation.

---

## Troubleshooting

| Problem | Fix |
|---|---|
| Custom domain keeps disconnecting on MacBook after sleep or Tailscale toggle | Create the permanent resolver file (see MacBook section above). This is the only real fix — it survives everything permanently. |
| Custom domain not opening on MacBook right now | Run in Terminal: `sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder` |
| Works Tailscale OFF but not Tailscale ON | Check `dnsmasq.conf` on Pi — `listen-address` line must have BOTH IPs: `listen-address=YOUR_LOCAL_IP,YOUR_TAILSCALE_IP` — Then: `sudo systemctl restart dnsmasq` |
| Works Tailscale ON but not Tailscale OFF | DNS order wrong on your device. Put `YOUR_LOCAL_IP` FIRST and `8.8.8.8` SECOND in DNS settings. |
| Samba (`smb://YOUR_CUSTOM_DOMAIN`) slow or sometimes fails | Add to `smb.conf` inside `[global]`: `dns proxy = no` and `name resolve order = host bcast` — Then: `sudo systemctl restart smbd` — Also add drive to Login Items: System Settings → General → Login Items → `+` → select mounted drive |
| Test if DNS is working | MacBook Terminal: `nslookup YOUR_CUSTOM_DOMAIN YOUR_LOCAL_IP` — Should show: `Name: YOUR_CUSTOM_DOMAIN` and `Address: YOUR_LOCAL_IP` — Verify resolver file: `scutil --dns | grep -A3 "YOUR_CUSTOM_DOMAIN_SUFFIX"` |
| Check dnsmasq is running on Pi | `sudo systemctl status dnsmasq` — Look for: `active (running)` |

> 💡 After any change to `/etc/dnsmasq.conf` on Pi always run: `sudo systemctl restart dnsmasq`

> 💡 After any change to DNS settings on MacBook always run: `sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder`

---

[← Automation](14-automation.md) | [Back to README](../README.md)
