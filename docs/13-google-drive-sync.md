# Part 13 — Transfer Files from Google Drive to Nextcloud

> **How it works:** Google Drive → rclone on Pi → 4TB HDD (Nextcloud). The tool rclone connects your Google Drive account to the Pi and transfers files directly. Nothing is downloaded to your MacBook. Your MacBook can sleep during transfer.

| What rclone does | Why it is the best method |
|---|---|
| Transfers directly inside the Pi | MacBook not involved at all |
| Smart resume — never copies same file twice | Safe to interrupt and restart anytime |
| Transfer specific folders only | You choose exactly what to transfer |
| Runs in background | MacBook can sleep — Pi keeps transferring |

---

## 13.1 — Install rclone on MacBook or Windows (one time only)

You need rclone on your computer only for the initial Google account authorization step. After that, your computer is not needed.

**On MacBook — install Homebrew first then rclone:**
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```
Press Enter when asked to continue. Enter your MacBook password when asked. Wait for installation to finish.
```bash
brew install rclone
```

**On Windows — download rclone directly:**
- Go to: https://rclone.org/downloads/
- Under Windows — click `rclone-current-windows-amd64.zip` → download
- Extract the zip file → open the folder → you will see `rclone.exe`
- Open PowerShell → navigate to the folder where `rclone.exe` is, for example:
```powershell
cd C:\Users\YourName\Downloads\rclone-current-windows-amd64
```
- All rclone commands on Windows must be run from this folder in PowerShell

Verify rclone installed correctly (MacBook) or working (Windows):
```bash
rclone version
```

✅ You should see a version number like: `rclone v1.73.1`. rclone is ready.

---

## 13.2 — Install rclone on Pi

SSH into Pi:
```bash
ssh YOUR_SSH_USERNAME@YOUR_LOCAL_IP
```

Install rclone:
```bash
sudo apt install rclone -y
```

---

## 13.3 — Configure Google Drive connection on Pi

Start rclone configuration:
```bash
rclone config
```

Answer each question exactly as shown:

| Question shown | Your answer |
|---|---|
| `n/s/q>` | Type: `n` → Enter (create new remote) |
| `name>` | Type: `googledrive` → Enter |
| Storage type / Option Storage Type | `drive` → Enter |
| `client_id>` | Just press Enter (leave blank) |
| `client_secret>` | Just press Enter (leave blank) |
| `scope>` (list of options) | Type: `1` → Enter (full access) |
| `root_folder_id>` | Just press Enter (leave blank) |
| `service_account_file>` | Just press Enter (leave blank) |
| Edit advanced config? y/n> | Type: `n` → Enter |
| Use auto config? y/n> | Type: `n` → Enter — **IMPORTANT: always choose n** |

Pi then shows a command like this — copy the ENTIRE line:
```
rclone authorize "drive" "eyJzY29wZSI6ImRyaXZlIn0"
```

> ⚠️ The code after `drive` in quotes will be different for you. Copy the exact command shown on YOUR Pi screen.

---

## 13.4 — Authorize Google Drive on MacBook

Keep the Pi terminal open. Open a **NEW Terminal window** on MacBook.

Paste the exact command Pi showed you into MacBook Terminal:
```bash
rclone authorize "drive" "eyJzY29wZSI6ImRyaXZlIn0"
```

A browser window opens automatically. Sign in with your Google account. Click Allow to grant access.

MacBook Terminal then shows a very long code starting with `eyJ...`
Copy the ENTIRE code from `eyJ` to the very last character.

Go back to Pi terminal. At `config_token>` paste the entire code → press Enter.

Answer the remaining questions:

| Question | Answer |
|---|---|
| Configure as Shared Drive? y/n> | Type: `n` → Enter |
| Keep this remote? y/e/d> | Type: `y` → Enter |
| e/n/d/r/c/s/q> | Type: `q` → Enter (quit config) |

---

## 13.5 — Copy rclone config to root (CRITICAL step)

Because we use `sudo` for file transfer, we must copy the config to root's location. Without this step the transfer fails with 'config file not found' error.

```bash
sudo mkdir -p /root/.config/rclone
sudo cp /home/YOUR_SSH_USERNAME/.config/rclone/rclone.conf /root/.config/rclone/rclone.conf
```

Verify it worked:
```bash
sudo rclone listremotes
```

✅ You should see: `googledrive:` This confirms Google Drive is connected and ready.

---

## 13.6 — Test Google Drive connection

```bash
rclone ls googledrive: --max-depth 1
```

You will see all your Google Drive files and folders listed. This confirms the connection is working perfectly.

---

## 13.7 — Create destination folder on 4TB drive

```bash
sudo mkdir -p /mnt/drive4tb/nextcloud-data/YOUR_NEXTCLOUD_ADMIN/files/4TB/GoogleDrive
sudo chown -R www-data:www-data /mnt/drive4tb/nextcloud-data/YOUR_NEXTCLOUD_ADMIN/files/4TB/GoogleDrive
```

Verify folder was created correctly:
```bash
sudo ls -la /mnt/drive4tb/nextcloud-data/YOUR_NEXTCLOUD_ADMIN/files/4TB/ | grep GoogleDrive
```

✅ You should see: `drwxr-xr-x www-data www-data GoogleDrive` Folder is ready.

---

## 13.8 — Transfer specific folders from Google Drive

You can transfer any specific folder from Google Drive. Transfer ONE folder at a time.

> ⚠️ Transfer ONE folder at a time. Wait for each transfer to finish before starting the next one. Each transfer uses a separate log file so they do not mix.

**Example — Transfer a folder:**
```bash
sudo nohup rclone copy "googledrive:YOUR_FOLDER_NAME" \
  /mnt/drive4tb/nextcloud-data/YOUR_NEXTCLOUD_ADMIN/files/4TB/GoogleDrive/YOUR_FOLDER_NAME/ \
  --transfers=4 --checkers=8 --drive-chunk-size=64M -v \
  > /home/YOUR_SSH_USERNAME/gdrive-copy.log 2>&1 &
```

> For folder names with spaces, put them in quotes: `"googledrive:Travel 2025"`

After running the command you will see a number like `[1] 18017` — transfer is running in background. MacBook can now sleep.

| Part of the command | What it means |
|---|---|
| `"googledrive:YOUR_FOLDER_NAME"` | Source — the folder in Google Drive |
| `/mnt/.../4TB/GoogleDrive/YOUR_FOLDER_NAME/` | Destination — where it saves on your 4TB HDD |
| `--transfers=4` | Download 4 files at the same time — faster transfer |
| `--drive-chunk-size=64M` | Upload in 64MB chunks — more reliable for large files |
| `> gdrive-copy.log` | Save progress to a log file you can check anytime |
| `2>&1 &` | Run in background — Pi keeps going even if MacBook sleeps |

---

## 13.9 — Check transfer progress

Watch live progress:
```bash
tail -f /home/YOUR_SSH_USERNAME/gdrive-copy.log
```

You will see files being copied with transfer speed and ETA. Press `Ctrl+C` to stop watching — transfer keeps running.

Check how much has been copied so far:
```bash
sudo du -sh /mnt/drive4tb/nextcloud-data/YOUR_NEXTCLOUD_ADMIN/files/4TB/GoogleDrive/YOUR_FOLDER_NAME/
```

Check if transfer is still running:
```bash
ps aux | grep rclone
```

If you see a line with `rclone` in it — still running. If you only see `grep rclone` — transfer has finished.

---

## 13.10 — If transfer gets interrupted — resume it

rclone is smart — it never copies already transferred files again. If interrupted just run the same command again — it skips completed files and continues from where it stopped.

---

## 13.11 — Make files appear in Nextcloud after transfer

After transfer finishes, run this scan so all new files appear in Nextcloud:
```bash
sudo -u www-data php /var/www/nextcloud/occ files:scan --all
```

After scan completes open Nextcloud in Safari — go to Files → 4TB → GoogleDrive to see all transferred files.

---

## 13.12 — Verify transfer is complete

**Step 1 — Check if transfer is still running:**
```bash
ps aux | grep rclone
```
If you see only `grep --color=auto rclone` — transfer is completely finished. ✅
If you see a long rclone line — still running, wait and check again later.

**Step 2 — Check how many files were transferred:**
```bash
sudo find /mnt/drive4tb/nextcloud-data/YOUR_NEXTCLOUD_ADMIN/files/4TB/GoogleDrive/ -type f | wc -l
```
This shows the total number of files. Compare with your Google Drive folder to confirm everything transferred.

**Step 3 — Check total size transferred:**
```bash
sudo du -sh /mnt/drive4tb/nextcloud-data/YOUR_NEXTCLOUD_ADMIN/files/4TB/GoogleDrive/
```
Compare this number with the folder size shown in Google Drive. They should match.

**Step 4 — Check the transfer log for any errors:**
```bash
cat /home/YOUR_SSH_USERNAME/gdrive-copy.log | grep -i error
```
If nothing shows — no errors during transfer. ✅
If errors show — run the transfer command again. rclone will skip already copied files and retry only the failed ones.

**Step 5 — Make all transferred files appear in Nextcloud:**
```bash
sudo -u www-data php /var/www/nextcloud/occ files:scan --all
```
After this open `http://YOUR_LOCAL_IP/nextcloud` → Files → 4TB → GoogleDrive folder — all files will be visible. ✅

---

## 13.13 — Quick reference for future transfers

| What | Command |
|---|---|
| Test Google Drive connection | `rclone ls googledrive: --max-depth 1` |
| Transfer specific folder | `sudo nohup rclone copy "googledrive:FolderName" /mnt/drive4tb/nextcloud-data/YOUR_NEXTCLOUD_ADMIN/files/4TB/GoogleDrive/FolderName/ --transfers=4 --checkers=8 --drive-chunk-size=64M -v > /home/YOUR_SSH_USERNAME/gdrive-copy.log 2>&1 &` |
| Watch live progress | `tail -f /home/YOUR_SSH_USERNAME/gdrive-copy.log` |
| Check size copied so far | `sudo du -sh /mnt/drive4tb/nextcloud-data/YOUR_NEXTCLOUD_ADMIN/files/4TB/GoogleDrive/` |
| Is transfer still running? | `ps aux \| grep rclone` |
| Scan files into Nextcloud | `sudo -u www-data php /var/www/nextcloud/occ files:scan --all` |
| Count transferred files | `sudo find /mnt/drive4tb/nextcloud-data/YOUR_NEXTCLOUD_ADMIN/files/4TB/GoogleDrive/ -type f \| wc -l` |

---

[← Crash Troubleshooting](12-crash-troubleshooting.md) | [Back to README](../README.md) | [Next: Automation →](14-automation.md)
