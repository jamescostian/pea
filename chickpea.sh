source /etc/pea.conf

warning=

if [ -r "$(dirname $OTP)" ] && [ -f "$OTP" ]; then
  warning="$OTP is present"
elif ! systemctl is-active -q pead.serivce ; then
  warning="pead.service is inactive"
fi

if [ -n "$warning" ]; then
  # blinking red text
  tput blink
  tput setaf 1
cat << EOF

    WARNING: $warning
    Disk will be automatically decrypted upon boot.

EOF
  tput sgr0
fi
