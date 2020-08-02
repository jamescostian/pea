#!/bin/bash -e

source $(which peat)

set -x
dd if=/dev/urandom of=$OTP bs=512 count=4
cryptsetup luksAddKey $DISK $OTP
systemctl stop pead
