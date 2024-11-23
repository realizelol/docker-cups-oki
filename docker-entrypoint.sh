#!/bin/bash
set -e
#set -x ## debug

# check for cupsd.conf existance
# if not exist re-copy it from skeleton
if [[ ! -f /etc/cups/cupsd.conf ]]; then
  cp -rpn /etc/cups-skel/* /etc/cups/
fi

# delete lock file if exists for any unknown reason
if ! pgrep -l pacman && test -f /var/lib/pacman/db.lck; then
  rm -vf /var/lib/pacman/db.lck
fi

# TrustedOnly sources
if ! grep -q "^SigLevel = Required DatabaseOptional TrustedOnly$" /etc/pacman.conf; then
  sed -ri "0,/SigLevel/{s/^(#?)(SigLevel\s*=\s*)(.*)/\2\3 TrustedOnly/}" /etc/pacman.conf
fi

# cleanup pacman cache
pacman -Sc  --noconfirm
pacman -Scc --noconfirm
rm -vf /var/cache/pacman/pkg/*

# refresh keys --> first try via upgrade error in next step --> otherwise:
#if [[ "$(pacman -Q archlinux-keyring | awk '{print$2}')" != "20241015-1" ]]; then
#  echo "updating archlinux repo keys... (may take a while)"
#  pacman -Sy archlinux-keyring --noconfirm >/dev/null
#  pacman-key --refresh-keys >/dev/null
#  exit # inform us by not running container via old keyring
#fi

# update packages in background if connected to www
( ( while ! ping -c3 -W3 archlinux.org >/dev/null; do sleep 2; done; \
    { pacman -Syy  --noconfirm && \
      pacman -Syyu --noconfirm && \
      pacman -Fyy  --noconfirm;   \
    } || \
    { \
      pacman -Sy archlinux-keyring --noconfirm && \
      pacman-key --refresh-keys                && \
      pacman -Fyy --noconfirm; \
    } \
)& )>/dev/null 2>&1

# fix papersize
echo 'a4' > /etc/papersize

# run cupsd
echo "$(date +'%Y-%m-%d - %H:%M:%S') - cups started successfully."
exec "${@}"
