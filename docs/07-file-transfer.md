# Part 7 — Transferring Files to Your NAS

---

## 7.1 — MacBook — Upload via Nextcloud browser

- Open `http://YOUR_LOCAL_IP/nextcloud` in Safari
- Click `+` **New** button → Upload file → select file from MacBook
- File goes directly to: `/mnt/drive4tb/nextcloud-data/YOUR_NEXTCLOUD_ADMIN/files/`

> ⚠️ Browser only supports individual files, not entire folders. For folder transfer use 7.2 or 7.3.

---

## 7.2 — MacBook — Sync folders via Nextcloud Desktop App

- Drag any folder into the Nextcloud folder in Finder
- Syncs automatically — entire folder structure preserved
- Best method for regular MacBook → NAS file sync

---

## 7.3 — MacBook — Drag and drop via Samba (Finder)

- Finder → `Command+K` → `smb://YOUR_LOCAL_IP` → mount `4TB`
- Open two Finder windows side by side — local files and NAS
- Drag and drop files directly into the NAS window
- Files appear in Nextcloud automatically within 5 minutes

---

## 7.4 — iPhone — Upload via Nextcloud App

- Open Nextcloud app → tap Files at bottom
- Tap `+` (top right) → Upload file → choose from Photos or Files
- File uploads directly to your 4TB HDD
- Auto photo backup: tap Menu → Settings → Auto Upload → turn ON
- Photos automatically back up to NAS whenever on WiFi

---

## 7.5 — iPhone — Copy files via Samba (Files App)

- Open Files app → tap Browse → Shared → tap `4TB`
- Long-press any file in your iPhone storage → Share → Save to Files
- Choose `4TB` as destination → tap Save
- File is now on your 4TB HDD

---

## 7.6 — Android — Upload via Nextcloud App

- Open Nextcloud app → tap `+` (bottom right) → Upload content
- Choose files from your Android storage → tap Upload
- Files upload directly to your 4TB HDD
- Auto photo backup: Menu → Settings → Auto Upload → enable

---

## 7.7 — Android — Copy files via Samba (CX File Explorer)

- Open CX File Explorer → Network → tap your NAS connection
- Navigate to the folder you want to save to
- Tap the copy/paste icon → navigate to your Android file → copy → paste into NAS folder

---

## 7.8 — Windows — Upload via Nextcloud Desktop App

- Drag any file or folder into the Nextcloud folder on your Windows computer
- Syncs automatically to your 4TB HDD — entire folder structure preserved
- Best method for regular Windows → NAS file sync

---

## 7.9 — Windows — Copy files via Samba (File Explorer)

- Open File Explorer → navigate to Z: drive (your mapped NAS drive)
- Simply drag and drop files from your Windows computer into the Z: drive
- Files copy directly to your 4TB HDD
- For global access: Tailscale must be ON in system tray first

Your 4TB drive contents visible in Nextcloud:

![Nextcloud 4TB folder — showing all transferred files and folders](../images/nextcloud-4tb-contents.png)

---

## 7.10 — Direct Pi-to-Pi copy (fastest for large transfers)

This copies directly inside the Pi from one drive to the other. Does not go through WiFi. Fastest method. MacBook can sleep, terminal can close — Pi keeps copying by itself.

Run this command — it runs in background safely:
```bash
sudo nohup rsync -av --chown=www-data:www-data /mnt/SOURCE-FOLDER/ \
  /mnt/drive4tb/nextcloud-data/YOUR_NEXTCLOUD_ADMIN/files/4TB/DESTINATION-FOLDER/ \
  > /home/YOUR_SSH_USERNAME/copy-progress.log 2>&1 &
```

> ⚠️ Replace `SOURCE-FOLDER` with your actual source path and `DESTINATION-FOLDER` with your folder name inside 4TB.

You will see a number like `[1] 12345` — this means it is running in background. You can now close the terminal and sleep your MacBook.

**Check progress anytime:**
```bash
tail -f /home/YOUR_SSH_USERNAME/copy-progress.log
```
Press `Ctrl+C` to stop watching — the copy keeps running.

**Check if still running:**
```bash
ps aux | grep rsync
```
If you see a line containing `rsync` — still running.

**After copy finishes — run this once to tell Nextcloud about all new files:**
```bash
sudo -u www-data php /var/www/nextcloud/occ files:scan --all
```

After this, all copied files appear in Nextcloud. From then on the automatic 5-minute cron handles any new files.

---

[← File Access](06-file-access.md) | [Back to README](../README.md) | [Next: Security →](08-security.md)
