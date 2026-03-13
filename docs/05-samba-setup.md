# Part 5 — Install Samba (Fast File Sharing — All Devices)

> **INFO:** Samba makes your 4TB drive appear as a normal network folder on MacBook Finder, iPhone Files app, Windows File Explorer, and Android. Samba and Nextcloud access the EXACT SAME FILES — no duplication at all.

---

## 5.1 — How Samba and Nextcloud share the same files

Each Samba share is pointed directly to the same location Nextcloud uses:

- **4TB share** → `/mnt/drive4tb/nextcloud-data/YOUR_NEXTCLOUD_ADMIN/files` (4TB drive)
- **650GB share** → `/mnt/650GB` (650GB drive — also visible in Nextcloud via bind mount)

When you upload a file via Nextcloud — it goes to this folder. When you copy a file via Samba — it goes to the same folder. Same physical location. No duplication. No confusion.

| Use Nextcloud when | Use Samba when |
|---|---|
| Accessing from another country | Transferring large files at home |
| Auto photo backup from iPhone/Android | Drag and drop folders from MacBook |
| Sharing files with others via link | Fast local file access like a USB drive |
| Both access exactly the same files | No duplication |

> **INFO:** Files added via Samba appear in Nextcloud automatically within 5 minutes. This is handled by the cron job set up in Part 3 Step 11. You never need to run any manual command.

---

## 5.2 — Install Samba

```bash
sudo apt update
sudo apt install samba samba-common-bin -y
```

Verify install worked:
```bash
smbd --version
```

---

## 5.3 — Back up original Samba config

```bash
sudo cp /etc/samba/smb.conf /etc/samba/smb.conf.backup
```

---

## 5.4 — Create new Samba configuration

```bash
sudo nano /etc/samba/smb.conf
```

Hold `Ctrl+K` to delete all existing content line by line until file is empty. Then paste this entire block exactly — replace `YOUR_NEXTCLOUD_ADMIN` and `YOUR_SAMBA_USERNAME` with your actual values:

```ini
[global]
workgroup = WORKGROUP
server string = RaspberryPi NAS
server role = standalone server
security = user
map to guest = never

# Required for macOS Tahoe and iPhone compatibility
vfs objects = catia fruit streams_xattr
fruit:metadata = stream
fruit:model = RackMac
fruit:posix_rename = yes
fruit:nfs_aces = no
fruit:wipe_intentionally_left_blank_rfork = yes
fruit:delete_empty_adfiles = yes

[4TB]
comment = 4TB Hard Drive
path = /mnt/drive4tb/nextcloud-data/YOUR_NEXTCLOUD_ADMIN/files
browseable = yes
read only = no
create mask = 0664
directory mask = 0775
valid users = YOUR_SAMBA_USERNAME
force user = www-data
guest ok = no

[650GB]
comment = 650GB Hard Drive
path = /mnt/650GB
browseable = yes
read only = no
create mask = 0664
directory mask = 0775
valid users = YOUR_SAMBA_USERNAME
force user = www-data
guest ok = no
```

Save: `Ctrl+X` → `Y` → `Enter`

> ⚠️ `force user = www-data` is CRITICAL. It ensures all files created via Samba are owned by `www-data` — the same user Nextcloud uses. Without this, Nextcloud cannot read files you add via Samba.

> ⚠️ The `vfs objects = catia fruit streams_xattr` lines are REQUIRED for macOS and iPhone. Without them Mac and iPhone may show shares as read-only or fail to connect.

---

## 5.5 — Test config for errors

```bash
testparm
```

Look for: `Loaded services file OK.`

The line `Weak crypto is allowed by GnuTLS` is a harmless warning — ignore it.

---

## 5.6 — Create Samba password for your user

```bash
sudo smbpasswd -a YOUR_SAMBA_USERNAME
```

Type password when asked, type again to confirm.

> ⚠️ The Samba password is separate from your SSH login password. Use your Samba password when connecting from MacBook/iPhone/Windows/Android.

---

## 5.7 — Start Samba and enable auto-start on boot

```bash
sudo systemctl restart smbd
sudo systemctl restart nmbd
sudo systemctl enable smbd
sudo systemctl enable nmbd
```

The perl locale warnings during enable are harmless — ignore them.

Verify Samba is running:
```bash
sudo systemctl status smbd
```

Look for: `active (running)` and `smbd: ready to serve connections` ✅

---

[← Tailscale VPN](04-tailscale-vpn.md) | [Back to README](../README.md) | [Next: File Access →](06-file-access.md)
