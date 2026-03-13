# Part 6 — Accessing Files from All Devices

---

## 6.1 — MacBook — Nextcloud (browser)

| Where you are | Address to use |
|---|---|
| Home WiFi | `http://YOUR_LOCAL_IP/nextcloud` |
| Anywhere globally (Tailscale ON) | `http://YOUR_TAILSCALE_IP/nextcloud` |

Login: `YOUR_NEXTCLOUD_ADMIN` / `YOUR_NEXTCLOUD_PASSWORD`

---

## 6.2 — MacBook — Nextcloud Desktop App

- Download: https://nextcloud.com/install/#install-clients → macOS
- Install → open → Log in → server: `http://YOUR_LOCAL_IP/nextcloud`
- Login: `YOUR_NEXTCLOUD_ADMIN` / `YOUR_NEXTCLOUD_PASSWORD`
- A Nextcloud folder appears in Finder — drag any files or folders in to sync automatically to 4TB drive

---

## 6.3 — MacBook — Samba (Finder)

**Home WiFi:**
- Finder → `Command+K` → type: `smb://YOUR_LOCAL_IP` → Connect
- Select Registered User → Username: `YOUR_SAMBA_USERNAME` → Password: `YOUR_SAMBA_PASSWORD`
- Select `4TB` → OK → appears in Finder sidebar under Locations

**From anywhere globally:**
- Make sure Tailscale icon in menu bar is active (connected)
- Finder → `Command+K` → type: `smb://YOUR_TAILSCALE_IP` → same login

**Auto-reconnect after restart or sleep (macOS fix):**
- System Settings → General → Login Items → click `+` → select the mounted drive

> **INFO:** macOS has a known Apple bug where SMB shares disconnect after sleep/restart. Adding to Login Items is the Apple-recommended workaround.

---

## 6.4 — iPhone — Nextcloud App

- App Store → search **Nextcloud** → install (by Nextcloud GmbH, free)
- Open → Log in → server address:

| Location | Server address |
|---|---|
| Home WiFi | `http://YOUR_LOCAL_IP/nextcloud` |
| Anywhere globally (Tailscale ON) | `http://YOUR_TAILSCALE_IP/nextcloud` |

Login: `YOUR_NEXTCLOUD_ADMIN` / `YOUR_NEXTCLOUD_PASSWORD`

*iPhone Nextcloud App — showing both 4TB and 650GB drives*

<img src="../images/iphone-nextcloud-drives.jpg" alt="iPhone Nextcloud App — showing both 4TB and 650GB drives as folders" width="300"/>

Inside the 4TB folder — all files and subfolders accessible from anywhere:

<img src="../images/iphone-nextcloud-4tb.jpg" alt="iPhone Nextcloud App — 4TB folder contents" width="300"/>

**Auto photo backup:**
- Tap menu (3 lines) → Settings → Auto Upload → turn ON

<img src="../images/iphone-auto-upload.jpg" alt="iPhone Nextcloud Auto Upload settings" width="300"/>

Photos automatically back up to 4TB drive whenever on the internet.

---

## 6.5 — iPhone — Samba (Files App)

- Open Files app → tap Browse at bottom
- Tap three dots `...` (top right) → Connect to Server
- Home WiFi: `smb://YOUR_LOCAL_IP` OR Global: `smb://YOUR_TAILSCALE_IP` (Tailscale ON)
- Tap Connect → Registered User → Name: `YOUR_SAMBA_USERNAME` → Password: `YOUR_SAMBA_PASSWORD` → Next
- You see: `4TB` and `650GB` — tap either to browse
- They save under Browse → Shared for future quick access

---

## 6.6 — Android — Nextcloud App

- Play Store → search **Nextcloud** → install (free)
- Log in → server: `http://YOUR_LOCAL_IP/nextcloud` → `YOUR_NEXTCLOUD_ADMIN` / `YOUR_NEXTCLOUD_PASSWORD`
- Auto photo backup: Menu → Settings → Auto Upload → enable

---

## 6.7 — Android — Samba (CX File Explorer)

- Play Store → search **CX File Explorer** → install (free)
- Open → tap Network at bottom → tap `+` → New Location → SMB
- Server: `YOUR_LOCAL_IP` (home) or `YOUR_TAILSCALE_IP` (global with Tailscale ON)
- Username: `YOUR_SAMBA_USERNAME` → Password: `YOUR_SAMBA_PASSWORD` → OK

---

## 6.8 — Windows — Nextcloud Desktop App

- Download: https://nextcloud.com/install/#install-clients → Windows
- Install → server: `http://YOUR_LOCAL_IP/nextcloud` → `YOUR_NEXTCLOUD_ADMIN` / `YOUR_NEXTCLOUD_PASSWORD`
- Enable **Virtual Files** mode to save local disk space — files appear but only download when opened

---

## 6.9 — Windows — Samba (File Explorer)

- Open File Explorer → right-click **This PC** → **Map network drive**
- Drive letter: `Z:` → Folder: `\\YOUR_LOCAL_IP\4TB` → check **Reconnect at sign-in** → Finish
- Enter: `YOUR_SAMBA_USERNAME` / `YOUR_SAMBA_PASSWORD` → OK
- Repeat for `Y:` with `\\YOUR_LOCAL_IP\650GB`
- For global access: use `\\YOUR_TAILSCALE_IP\4TB` (Tailscale icon in tray must be ON)

---

[← Samba Setup](05-samba-setup.md) | [Back to README](../README.md) | [Next: File Transfer →](07-file-transfer.md)
