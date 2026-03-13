# Part 4 — Install Tailscale VPN (Secure Global Access)

> **INFO:** Tailscale creates a secure private tunnel between your devices. Access Pi from anywhere in the world — no port forwarding on router needed. Free for personal use up to 100 devices.

---

## 4.1 — Create free Tailscale account

- On MacBook go to: https://tailscale.com → Get Started
- Sign up with Google, Apple, GitHub, or Microsoft — no credit card
- Write down which account you used — **ALL devices must use the same account**

---

## 4.2 — Install Tailscale on the Pi

```bash
curl -fsSL https://tailscale.com/install.sh | sh
```

After install completes:
```bash
sudo tailscale up
```

A URL appears like: `https://login.tailscale.com/a/xxxxxxxxxx`
Copy that URL → open in Safari on MacBook → log in with your Tailscale account → Pi is now registered.

```bash
sudo systemctl enable tailscaled
```

---

## 4.3 — Get your Pi's permanent Tailscale IP

```bash
tailscale ip -4
```

✅ This IP never changes even when your home internet IP changes. It is your permanent global address for the Pi.

---

## 4.4 — CRITICAL: Disable key expiry on Pi

> ⚠️ Without this, Tailscale disconnects your Pi after 180 days and you cannot reconnect remotely without physical access. Do this step now.

- Go to: https://login.tailscale.com/admin/machines
- Find `naspi` in the device list
- Click the three dots `...` next to naspi
- Click **Disable key expiry** → confirm

✅ Key expiry disabled. Pi stays connected to Tailscale permanently.

---

## 4.5 — Install Tailscale on MacBook

- Go to: https://tailscale.com/download → Download for Mac → install
- Click Tailscale icon in menu bar (top right of screen) → Log in → same Tailscale account
- Allow System Extension when popup appears: click Install Now
- Then click Open Settings → System Settings opens → find Tailscale Network Extension → click Allow
- Enter MacBook password if asked

✅ Tailscale icon in menu bar = VPN is active. Your MacBook can now reach Pi at your Tailscale IP.

---

## 4.6 — Install Tailscale on iPhone

- App Store → search **Tailscale** → install (by Tailscale Inc., free)
- Open → Sign in → same Tailscale account → turn toggle ON

✅ iPhone can now reach Pi from anywhere — home WiFi, mobile data, hotel WiFi, abroad.

---

## 4.7 — Install Tailscale on Android

- Play Store → search **Tailscale** → install → same account → toggle ON

---

## 4.8 — Install Tailscale on Windows

- Go to: https://tailscale.com/download → Download for Windows → install
- Sign in with same account → Tailscale icon appears in system tray (bottom right)

---

## 4.9 — Verify everything is connected

Check from Pi terminal:
```bash
tailscale status
```

You should see all your devices listed with their Tailscale IPs.

**Test global access from iPhone (simulate being abroad):**
- Turn WiFi OFF on iPhone (Settings → WiFi → OFF) — now only on mobile data
- Make sure Tailscale is ON on iPhone
- Open Safari → go to: `http://YOUR_TAILSCALE_IP/nextcloud`
- You should see Nextcloud login from mobile data — global access works! ✅
- Turn WiFi back ON when done testing

---

[← Nextcloud Setup](03-nextcloud-setup.md) | [Back to README](../README.md) | [Next: Samba Setup →](05-samba-setup.md)
