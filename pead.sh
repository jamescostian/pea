#!/bin/bash -e
source $(which peat)

why='next boot will require manual entry of password to decrypt disk, please run pea'

if [ -f "$OTP" ]; then
  cryptsetup luksRemoveKey $DISK $OTP || echo "warn: $OTP was invalid"
  rm -v $OTP

else
  echo OTP file $OTP not found
fi 

systemd-notify --ready
systemd-inhibit --who=pea --why="$why" sleep infinity
