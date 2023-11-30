# Fork of [pea: Prepare Encrypted Auto-boot](https://gitlab.com/jennydaman/pea)

Let's say you have a server sitting around with FDE set up, and you want to reboot it. Normally, you'd have to phyiscally find that exact machine and type in your passphrase to decrypt the drive when it comes online.

After setting up pea, you can run `pea && reboot` instead of `reboot` and `pea` will set up a one-time passphrase that will decrypt your drive when it boots. After it boots, the one-time passphrase will be revoked by the pea daemon, `pead`, so that it can no longer unlock your computer (make it a one-time passphrase), and removed from your boot partition.

## Security

See [passless-boot's docs on this](https://gitlab.com/Marcool04/passless-boot/-/tree/67785e38b024348c24cb87044b914b8b6d1485e7#security-considerations-and-threat-model). passless-boot is similar to pea (both the original and this fork). One thing missing from that link: if you reboot and pead.service is never run by systemd (e.g. because your system is not bootable), then your boot disk will contain the OTP in cleartext until you fix that system. And finally:

:warning: If you provide your decryption passphrase in the config, then be sure that `/etc` is encrypted - if you have a separate, unencrypted partition you're mounting on `/etc`, then you _will_ leak your decryption passphrase :warning:

## Key differences

1. The original was built for arch users using `mkinitcpio`, this is built for Debian, Ubuntu, etc users using `initramfs-tools`. `mkinitcpio` comes with a really handy `encrypt` hook (or `sd-encrypt` if you're using systemd), which they were able to take advantage of. Here, we generate a new initramfs with the OTP baked in
2. The original required manually writing configuration files and adjusting one's kernel boot params and initramfs for all use cases. This one can be set up without any manual intervention or input as long as you only have 1 entry in `/etc/crypttab`
3. Instead of entering your decryption key every time you run `pea`, you can optionally you enter it once when configuring pea, and it will be saved to your disk under `/etc/pea.conf`

## Assumptions

1. You're using LUKS with a password, and no keyfile needs to be set in /etc/crypttab (besides the one `pea` will set for you)
2. You're using `initramfs-tools`
3. You use `UUID=...` in the second column of your `/etc/crypttab`
4. You only have 1 drive in /etc/crypttab - if not, it's ok, but you'll have to modify `pea.conf` yourself. `make config` will fail and tell you to make those edits
5. Some basic programs like `make` must be installed. If they're not, you'll get an error at install time (not runtime)

# Setup

0. Make sure the assumptions above work for you
1. Clone this repo and `cd` into it
2. `make config` or edit `pea.conf` yourself
3. (Optional) If you don't want to have to type your decryption passphrase every time you run `pea`, add `DECRYPTION_PASSPHRASE=...` to `pea.conf` where `...` is your decryption passphrase
4. `sudo make install`
5. (Optional) delete this repo locally, you no longer need it

Now you can run `pea && reboot` and the system will reboot without asking you for your password.

To reboot or shutdown without storing your password (forcing you to type it again after booting), use `systemctl stop pead` first. pea will use systemd-inhibit to tell systemd not to reboots unless you've run pea, which is why you should first stop `pead`. You may not need to though - systemd doesn't like to respect its own systemd-inhibit in many circumstances, and considers this to not be a bug. If you want good guardrails against rebooting without running pea, you should resort to hacks like setting `RefuseManualStart=yes` on `reboot.target`, `poweroff.target`, etc or use [reboot-guard](https://github.com/ryran/reboot-guard) to do that for you.

The same applies to shutdown.

# Adjustments

## Changing your passphrase

If you change your passphrase and you had already set `DECRYPTION_PASSPHRASE` in your `pea.conf`, you will need to edit `/etc/pea.conf` and update it there.

## LUKS volume UUID changes

If the UUID in your `/etc/crypttab` changes, you'll need to adjust `/etc/pea.conf` as well
