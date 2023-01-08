#!/bin/bash
set -e
#set -x ## debug

if [[ ! -f /etc/cups/cupsd.conf ]]; then
  cp -rpn /etc/cups-skel/* /etc/cups/
fi

# update packages in background if connected to www
( ( while ! ping -c3 -W3 archlinux.org; do sleep 2; done; \
    pacman -Syy  --noconfirm && \
    pacman -Syyu --noconfirm && \
    pacman -Fyy  --noconfirm \
)& )>/dev/null 2>&1

# fix papersize
echo 'a4' > /etc/papersize

# run cupsd
echo "$(date +'%Y-%m-%d - %H:%M:%S') - cups started successfully."
exec "${@}"
