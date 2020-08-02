# PeaTest: check argument is LUKS device and /boot is mounted

set -e

if [ -z "$DISK" ]; then
  echo "DISK not specified"
	exit 1
fi
if ! cryptsetup isLuks $DISK; then
	echo $DISK is not LUKS encrypted.
	exit 1
fi

mountpoint /boot
