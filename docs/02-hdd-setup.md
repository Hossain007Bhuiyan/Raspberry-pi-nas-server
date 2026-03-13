# Part 2 — Connect HDDs and Mount Drives

---

## 2.1 — Connect RSHTECH docking station

> **About the drives used:** This setup uses two personal HDDs — a new **4TB Seagate IronWolf** as the main storage drive and an older **650GB laptop HDD** as a secondary volume. Both are connected through a single RSHTECH USB 3.0 docking station. If you have different drives, the same steps apply regardless of brand or size.

- Insert 4TB HDD (3.5 inch) into Bay A of dock
- Insert 650GB HDD (2.5 inch) into Bay B of dock
- Connect 12V power adapter to dock and wall socket
- Connect USB 3.0 cable from dock to a **blue USB 3.0 port** on Pi (blue = USB 3.0 = faster)
- Turn on power switch on back of dock — drive lights should turn on

> ⚠️ Connect dock power FIRST, then USB cable to Pi. Never connect or disconnect HDDs while Pi is running — always shut down first.

---

## 2.2 — Format 650GB drive to ext4 (one time only)

The 650GB drive must be formatted to ext4 for full compatibility with Nextcloud and Samba. This gives proper Linux permission support.

> ⚠️ This erases all data on the 650GB drive. Make sure all important data is already moved to the 4TB drive before doing this.

Wipe all existing partitions and create one clean partition:
```bash
sudo fdisk /dev/sdb
```

Inside fdisk — type each of these one at a time:
```
d    (delete partition — repeat until all partitions deleted)
n    (new partition)
p    (primary)
1    (partition number 1)
     (press Enter — default first sector)
     (press Enter — default last sector — uses full disk)
w    (write and exit)
```

Format as ext4:
```bash
sudo mkfs.ext4 -L 650GB /dev/sdb1
```

Wait for this to complete — takes 1 to 2 minutes. You will see: `done` on each line.

---

## 2.3 — Verify both drives are detected

```bash
lsblk
```

| What you see | What it is |
|---|---|
| `sda` (3.6T) with `sda1` | Your 4TB HDD — ext4 format |
| `sdb` (596G) with `sdb1` | Your 650GB HDD — ext4 format — one clean partition after formatting |
| `mmcblk0` (119G) | Your microSD card — **NEVER touch this** |

---

## 2.4 — Find UUIDs of both drives

```bash
sudo blkid
```

> ⚠️ Always use UUID in fstab, never device names like `sdc` or `sdd`. Device names can swap after reboot but UUIDs never change.

Write down your UUIDs — you will need them in the next step:
- **4TB — sda1 — ext4:** `YOUR_4TB_UUID`
- **650GB — sdb1 — ext4:** `YOUR_650GB_UUID`

---

## 2.5 — Create mount point folders

```bash
sudo mkdir -p /mnt/drive4tb
sudo mkdir -p /mnt/650GB
```

---

## 2.6 — Configure auto-mount (fstab)

Back up fstab first — always do this before editing:
```bash
sudo cp /etc/fstab /etc/fstab.backup
```

Open fstab for editing:
```bash
sudo nano /etc/fstab
```

Add these two lines at the **VERY BOTTOM** of the file. Replace UUIDs with your actual UUIDs:
```
UUID=YOUR_4TB_UUID /mnt/drive4tb ext4 defaults,auto,nofail,noatime 0 2
UUID=YOUR_650GB_UUID /mnt/650GB ext4 defaults,nofail 0 2
/mnt/650GB /mnt/drive4tb/nextcloud-data/YOUR_NEXTCLOUD_ADMIN/files/650GB none bind 0 0
```

| Option | Why it matters |
|---|---|
| `nofail` | **CRITICAL:** Pi still boots if drive is disconnected. Without this, missing drive = Pi refuses to boot = locked out remotely forever |
| `noatime` | Does not update last-accessed timestamp — reduces unnecessary writes, extends drive life |
| `0 2` | Check drive integrity at boot after root filesystem is checked |
| `bind` | Makes 650GB drive appear as a folder inside Nextcloud |

Save: `Ctrl+X` → `Y` → `Enter`

Test mounts immediately without rebooting:
```bash
sudo mount -a
df -h | grep /mnt
```

✅ You should see both drives listed. 4TB shows ~3.6T total, 650GB shows ~586G total.

![Terminal showing both drives mounted with lsblk and df -h](../images/terminal-drives-mounted.png)

Set ownership so Nextcloud can access the 650GB drive:
```bash
sudo chown -R www-data:www-data /mnt/650GB
sudo chmod -R 755 /mnt/650GB
```

Create the 650GB folder inside Nextcloud and apply bind mount:
```bash
sudo mkdir -p /mnt/drive4tb/nextcloud-data/YOUR_NEXTCLOUD_ADMIN/files/650GB
sudo chown www-data:www-data /mnt/drive4tb/nextcloud-data/YOUR_NEXTCLOUD_ADMIN/files/650GB
sudo systemctl daemon-reload
sudo mount -a
```

✅ The 650GB drive is now visible inside Nextcloud as a folder called `650GB` — same as 4TB drive.

---

[← OS Installation](01-os-installation.md) | [Back to README](../README.md) | [Next: Nextcloud Setup →](03-nextcloud-setup.md)
