# Part 9 — Troubleshooting Common Issues

---

## 9.1 — File upload fails with Unknown error or RedisException

**Cause:** Redis socket path is wrong in config.php

**Fix:**
```bash
sudo nano /var/www/nextcloud/config/config.php
```

Make sure the Redis section looks exactly like this:
```php
'memcache.locking' => '\OC\Memcache\Redis',
'redis' => [
    'host' => '127.0.0.1',
    'port' => 6379,
],
```

```bash
sudo systemctl restart apache2
```

---

## 9.2 — Access through untrusted domain error

**Cause:** IP not in trusted_domains

**Fix:** Add your IPs to config.php — see [Part 3 Step 9](03-nextcloud-setup.md#39--fix-access-through-untrusted-domain-error)

---

## 9.3 — Nextcloud browser redirect fails after install

**Cause:** Chrome strips the IP from the redirect URL

**Fix:** Open Safari and manually type: `http://YOUR_LOCAL_IP/nextcloud`

---

## 9.4 — Drive not mounting after reboot

```bash
sudo cat /etc/fstab
sudo mount -a
```

Check for error messages. Most common cause: wrong UUID or missing `nofail` option.

---

## 9.5 — Samba connection refused or cannot connect

```bash
sudo systemctl status smbd
sudo systemctl restart smbd
testparm
```

If `testparm` shows errors — check smb.conf for typos. Make sure no lines are missing.

---

## 9.6 — Cannot find Pi on network after reboot

```bash
ping naspi.local
```

If no reply — check router admin page for current IP. Use that IP to SSH.

---

## 9.7 — Files added via Samba not appearing in Nextcloud

Wait 5 minutes — automatic rescan runs every 5 minutes. Or run manually:
```bash
sudo -u www-data php /var/www/nextcloud/occ files:scan --all
```

---

## 9.8 — Perl locale warnings during Samba enable

These warnings are completely harmless — they do not affect functionality. Samba works perfectly despite them. You can fix them with:
```bash
sudo locale-gen en_GB.UTF-8
sudo update-locale LANG=en_GB.UTF-8
```

---

## 9.9 — If 9.7 not working, Nextcloud scan stuck with "Another process is already scanning"

This happens when a previous scan was interrupted and left a lock in Redis cache.
```bash
sudo redis-cli FLUSHALL
sudo -u www-data php /var/www/nextcloud/occ files:scan --all
```

---

[← Security](08-security.md) | [Back to README](../README.md) | [Next: Quick Reference →](10-quick-reference.md)
