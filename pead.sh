#!/bin/bash -e
source $(which peat)

why='next boot will require manual entry of password to decrypt disk, please run pea'

if [ -f /boot/ot.pea ]; then
  cryptsetup luksRemoveKey $DISK /boot/ot.pea
  rm -v /boot/ot.pea

else
  echo Not booted using pea
fi 

systemd-notify --ready
systemd-inhibit --who=pea --why="$why" sleep infinity
