#!/usr/bin/env bash
set -e
source $(which peat)

sudo dd if=/dev/urandom of=$OTP bs=512 count=4
if [ -z "$DECRYPTION_PASSPHRASE" ]; then
  sudo cryptsetup luksAddKey $DISK $OTP
else
  echo "$DECRYPTION_PASSPHRASE" | sudo cryptsetup luksAddKey $DISK $OTP
fi
sudo chmod 0700 $OTP

sudo awk -i inplace /$(echo $DISK | sed 's~/dev/disk/by-uuid/~UUID=~')/'{$3="/etc/cryptsetup-keys.d/" $1 ".key"}1' /etc/crypttab
sudo systemd-inhibit --who=pea --why="regenerating initramfs" update-initramfs -ck all

sudo systemctl stop pead
