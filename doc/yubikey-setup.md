# YubiKey 5C Setup — Fedora 44

Cheat sheet for: YubiKey configuration, LUKS disk unlock, login/sudo with PAM, and SSH keys.

> Replace `/dev/nvme0n1p3` with your LUKS partition (find it with `lsblk -f`, type `crypto_LUKS`).

---

## 1. YubiKey basics

### Install the management tool
```bash
sudo dnf install yubikey-manager
```

### Check the key
```bash
ykman info              # FIDO2 must be "Enabled" under USB
ykman fido info         # shows whether a FIDO2 PIN is set
```

If FIDO2 is disabled:
```bash
ykman config usb --enable FIDO2
```

### FIDO2 PIN
```bash
ykman fido access change-pin                 # set the PIN (first time)
ykman fido access change-pin --pin OLDPIN    # change an existing PIN
```

- The PIN belongs **only to FIDO2**. It is shared by passkeys, LUKS, pam_u2f and SSH `-sk` keys.
- 4 to 63 characters, letters allowed.
- After 3 wrong tries in a row, unplug and replug the key. After 8 wrong tries in total, FIDO2 is locked.
- ⚠️ `ykman fido reset` wipes **all** passkeys and FIDO2 credentials (LUKS, SSH, websites).

### LED meanings
| LED | Meaning |
|---|---|
| Steady | Powered, idle |
| Blinking | Waiting for a touch |
| Brief flash | Plugged in / touch acknowledged |
| Off | No power / not detected |

### Stop accidental OTP strings (`cccccc…`)
Touching the key when nothing is waiting makes it type a Yubico OTP and press Enter.

```bash
ykman otp info                      # check what is in slots 1 and 2
```

Pick one:
```bash
ykman config usb --disable OTP      # turns off the whole OTP app (undo with --enable OTP)
ykman otp delete 1                  # remove only the short-touch OTP (keeps slot 2)
ykman otp swap                      # move OTP to long press (~3 s); swaps slots 1 and 2
```

⚠️ If slot 2 holds HMAC challenge-response (e.g. for KeePassXC), **don't** disable OTP. Use `ykman otp delete 1` instead.
None of these affect FIDO2 (LUKS, passkeys, SSH).

---

## 2. LUKS disk unlock with the YubiKey (FIDO2)

### Check the requirements
```bash
sudo cryptsetup luksDump /dev/nvme0n1p3 | grep Version   # must be 2
systemctl --version                                       # systemd ≥ 248
```

### Back up the LUKS header (do this first)
```bash
sudo cryptsetup luksHeaderBackup /dev/nvme0n1p3 --header-backup-file ~/luks-header.img
```
Keep a copy somewhere other than this disk.

### Enroll the YubiKey
```bash
sudo systemd-cryptenroll --fido2-device=auto /dev/nvme0n1p3
```
It asks for: the current passphrase, then the YubiKey PIN, then a touch (possibly two touches). Wait for the key to **blink** before touching it.

### Check the enrollment
```bash
sudo systemd-cryptenroll /dev/nvme0n1p3     # should list both "password" and "fido2"
```

### Use the key at boot: `/etc/crypttab`
```bash
sudoedit /etc/crypttab
```
Edit the **existing** line; don't add a second one:
```
luks-<uuid> UUID=<uuid> none discard,fido2-device=auto
```

### Include FIDO2 support in the initramfs
```bash
sudo dnf install libfido2
echo 'add_dracutmodules+=" fido2 "' | sudo tee /etc/dracut.conf.d/fido2.conf
```

### Rebuild the initramfs (GRUB layout: images in `/boot`)
`dracut --regenerate-all` may try to write to `/boot/efi/<machine-id>/…` and fail. Use explicit paths instead:

```bash
ls /boot/initramfs-*.img

# current kernel only
sudo dracut -f /boot/initramfs-$(uname -r).img $(uname -r)

# or every installed kernel
for v in $(ls /lib/modules); do
  [ -f /boot/vmlinuz-$v ] && sudo dracut -f /boot/initramfs-$v.img $v
done
```
Each run takes about 30 s to 2 min. Check progress with `top` (look for dracut/cpio/zstd).

### Check the initramfs
```bash
ls -l /boot/initramfs-$(uname -r).img                              # timestamp = now
sudo lsinitrd /boot/initramfs-$(uname -r).img -f etc/crypttab      # must show fido2-device=auto
sudo lsinitrd /boot/initramfs-$(uname -r).img | grep -i fido       # must show libfido2
```

### Most reliable fix: kernel command line option
```bash
sudo grubby --update-kernel=ALL --args="rd.luks.options=fido2-device=auto"
```

### Test
1. Reboot **with** the key plugged in: PIN prompt, then touch when it blinks.
2. Reboot **without** the key: it should fall back to the passphrase.

### Troubleshooting
```bash
journalctl -b -u 'systemd-cryptsetup@*' --no-pager
cat /proc/cmdline
cat /etc/crypttab
cat /etc/dracut.conf.d/fido2.conf
```

### Manage key slots
```bash
sudo systemd-cryptenroll --fido2-device=auto /dev/nvme0n1p3     # enroll a second YubiKey
sudo systemd-cryptenroll --wipe-slot=fido2 /dev/nvme0n1p3       # remove all FIDO2 enrollments
sudo cryptsetup luksChangeKey /dev/nvme0n1p3                     # change the passphrase
```
⚠️ Never wipe the passphrase slot. It is your recovery.

### Optional: new volume key (only if the old passphrase or header may be compromised)
```bash
sudo cryptsetup reencrypt /dev/nvme0n1p3
```
Back up your data first and keep the laptop on AC power. Afterwards, delete old header backups and make a new one.

---

## 3. Login, lock screen and sudo (pam_u2f)

### Install and register the key
```bash
sudo dnf install pam-u2f pamu2fcfg
mkdir -p ~/.config/Yubico
pamu2fcfg -N > ~/.config/Yubico/u2f_keys      # -N = require PIN + touch
```
Second key: `pamu2fcfg -n -N` and paste the output **on the same line** in `u2f_keys`.

### Enable it (keep a root shell open while testing: `sudo -i`)
```bash
sudo authselect enable-feature with-pam-u2f        # key OR password
# or
sudo authselect enable-feature with-pam-u2f-2fa    # password AND key
```

### Test in a new terminal
```bash
sudo -k; sudo true
```

### Undo
```bash
sudo authselect disable-feature with-pam-u2f
sudo authselect disable-feature with-pam-u2f-2fa
```

Note: logging in with the key instead of the password means KWallet won't unlock automatically.

---

## 4. SSH keys on the YubiKey

### Create a key
```bash
ssh-keygen -t ed25519-sk -O resident -O verify-required -C "baptiste-yubikey"
```
- The private key never leaves the YubiKey. `~/.ssh/id_ed25519_sk` is just a handle.
- A passphrase is optional; the PIN + touch already protect it.

### Install the public key
```bash
ssh-copy-id -i ~/.ssh/id_ed25519_sk.pub user@server
```
For GitHub/GitLab, paste the contents of `id_ed25519_sk.pub` into the SSH keys settings.

### Connect
```bash
ssh user@server        # PIN + touch
```

### Use on another computer
```bash
# Save the handle files
mkdir -p ~/.ssh && cd ~/.ssh
ssh-keygen -K
mv id_ed25519_sk_rk id_ed25519_sk
mv id_ed25519_sk_rk.pub id_ed25519_sk.pub

# Or load into the agent without writing files (shared/borrowed machine)
ssh-add -K
```
- Linux: OpenSSH ≥ 8.2 + `libfido2`
- Windows: built-in OpenSSH works
- macOS: `brew install openssh` (Apple's ssh has no FIDO support)

Second YubiKey: create a separate `-sk` key on it and add **both** `.pub` keys to each server.

---
