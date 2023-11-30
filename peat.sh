#!/usr/bin/env bash
# PeaTest: assert that disk is a LUKS device

if [ -f /etc/pea.conf ]; then
  source /etc/pea.conf
fi

set -e

if [ -z "$DISK" ]; then
  echo "DISK not specified"
	exit 1
fi
if ! sudo cryptsetup isLuks $DISK; then
	echo $DISK is not LUKS encrypted.
	exit 1
fi

if [ -z "$OTP" ]; then
  echo "OTP not specified"
	exit 1
fi
