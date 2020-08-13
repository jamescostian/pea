# pea: Prepare Encrypted Auto-boot

> Impeads poweroff until pea'd

Problem: with full-disk encryption, you cannot reboot your machine remotely
since it will ask for a password during boot.

Existing solution: install a SSH server in the initial ramdisk

- https://wiki.archlinux.org/index.php/Dm-crypt/Specialties#Remote_unlocking_of_the_root_(or_other)_partition
- https://benediktkr.github.io/ops/2015/05/01/remote-fde.html

Drawbacks: ssh identity is stored unencrypted.

## Proposal

Before a remote reboot, the machine is in a trusted state.
You must run the command `pea` to generate a one-time password/token (OTP)
which is used during startup to descrypt the root partition.

After each successful boot, the current OTP is immediately invalidated. The OTP is shortlived.

Drawbacks: if you accidentally reboot without running `pea` first, sucks to suck. Get in a car.

## Precondition

`/` is LUKS-encrypted. You will need an unencrypted partition:
the EFI system partition (ESP) is suitable, it is typically mounted at `/boot`.

## Installation

```bash
sudo make install
```

Edit `/etc/pea.conf` to configure your root partition device and OTP location.

```env
DISK=/dev/sda2
OTP=/boot/ot.pea
```

Enable and start the daemon.

```bash
sudo systemctl enable --now pead
```

You shouldn't be allowed to run `systemctl reboot` anymore.

## Components

`pead`: systemd service (daemon) which inhibits poweroff until `pea` is ran

`pea`: command to generate `/boot/ot.pea` and stop `pead`

`peat`: helper script to check arguments

## Boot Loader

Include the [`vfat`](https://wiki.archlinux.org/index.php/Dm-crypt/Device_encryption#Configuring_mkinitcpio) module
and the [`encrypt`](https://wiki.archlinux.org/index.php/Dm-crypt/Encrypting_an_Entire_System#Configuring_mkinitcpio) hook
in the initial ramdisk.

Assuming `otp.pea` is on `/dev/sda1` (probably the EFI system partition),
add the kernel parameter `cryptkey=/dev/sda1:vfat:/ot.pea` to kernel parameters.
In case the keyfile cannot be used (missing or misconfigured), the kernel will
resort to taking in a password from the keyboard.

## MOTD

Consider putting this in your `/etc/profile`

```bash
source /etc/pea.conf
if [ -f "$OTP" ]; then
  tput blink
  tput setaf 1
  cat << EOF

    WARNING: $OTP is present
    Disk will be automatically decrypted upon boot.

EOF
  tput sgr0
fi
```
