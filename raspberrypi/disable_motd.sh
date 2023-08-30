#!/bin/sh

DATE="$(date +%s)"

if [ -z "${DATE}" ]; then
  DATE=default
fi

getent passwd |
    awk -F: '($3 >= 1000 || $3 == 0) && $7 !~ /nologin|false$/ { print $6 "/.hushlogin" }' |
    xargs -I {} sh -c "echo '${DATE}' | tee -a {} > /dev/null"

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
