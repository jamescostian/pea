#!/bin/bash -e

source $(which peat)

set -x
dd if=/dev/urandom of=/boot/ot.pea bs=1M count=1 status=progress
cryptsetup luksAddKey $DISK /boot/ot.pea
systemctl stop pead
