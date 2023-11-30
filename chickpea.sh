source /etc/pea.conf

warning=

if [ -r "$(dirname $OTP)" ] && [ -f "$OTP" ]; then
  warning="$OTP is present. Disk will be automatically decrypted upon boot."
elif ! systemctl is-active -q pead.service ; then
  warning="pead.service is inactive. You can shutdown or reboot without running pea."
fi

if [ -n "$warning" ]; then
  # blinking red text
  tput blink
  tput setaf 1
cat << EOF

    WARNING: $warning

EOF
  tput sgr0
fi
