#!/bin/bash
set -e
set -x

if [[ ! -f /etc/cups/cupsd.conf ]]; then
  cp -rpn /etc/cups-skel/* /etc/cups/
fi

# update packages if connected to www
if ping -c3 -W3 archlinux.org &>/dev/null; then
  pacman -Syy  --noconfirm
  pacman -Syyu --noconfirm
  pacman -Fyy  --noconfirm
fi

# fix papersize
echo 'a4' > /etc/papersize

# run cupsd
echo "$(date +'%Y-%m-%d - %H:%M:%S') - cups started successfully."
exec "$@"
