#!/usr/bin/env bash
set -e
source $(which peat)

if [ -f "$OTP" ]; then
  awk -i inplace /$(echo $DISK | sed 's~/dev/disk/by-uuid/~UUID=~')/'{$3="none"}1' /etc/crypttab
  systemd-inhibit --who=pea --why="regenerating initramfs" update-initramfs -ck all
  cryptsetup luksRemoveKey $DISK $OTP || echo "warn: $OTP was invalid"
  echo "The old OTP has been revoked"
else
  echo OTP file $OTP not found
fi

systemd-notify --ready
systemd-inhibit --who=pea --why="next boot will require manual entry of passphrase to decrypt disk, please run pea, or if you want to have to decrypt manually upon reboot, run sudo systemctl stop pead" sleep infinity
