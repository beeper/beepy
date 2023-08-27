#!/bin/sh

sudo_user=${SUDO_USER:-$(whoami)}
sudo_user_home=$(eval echo "~${sudo_user}")

touch "${sudo_user_home}/.hushlogin"

DATE="$(date +%s)"

if [ -z "${DATE}" ]; then
  DATE=default
fi

if [ -e "/etc/update-motd.d/10-uname" ]; then
  chmod -x /etc/update-motd.d/10-uname*
  mv -f "/etc/update-motd.d/10-uname" "/etc/update-motd.d/10-uname.backup.${DATE}"
fi

if [ -e "/etc/motd" ]; then
  mv -f "/etc/motd" "/etc/motd.backup.${DATE}"
fi

if [ -e "/etc/issue" ]; then
  mv -f "/etc/issue" "/etc/issue.backup.${DATE}"
fi
