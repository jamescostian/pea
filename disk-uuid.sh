#!/usr/bin/env bash
# Given UUID=xyz or /dev/... convert it to just the UUID
if echo "$1" | grep UUID= > /dev/null; then
  echo "$1" | sed 's~UUID=~~'
else
  blkid -s UUID -o value "$1"
fi