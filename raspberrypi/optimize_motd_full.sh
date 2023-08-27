#!/bin/sh

sudo_user=${SUDO_USER:-$(whoami)}
sudo_user_home=$(eval echo ~$sudo_user)
touch "$sudo_user_home/.hushlogin"

# Check for 10-uname
if [ -e "/etc/update-motd.d/10-uname" ]; then
  chmod -x /etc/update-motd.d/10-uname*
  mv -f /etc/update-motd.d/10-uname /etc/update-motd.d/10-uname.backup.$(date +%s)
fi

# Check for motd
if [ -e "/etc/motd" ]; then
  mv -f /etc/motd /etc/motd.backup.$(date +%s)
fi

# Check for issue
if [ -e "/etc/issue" ]; then
  mv -f /etc/issue /etc/issue.backup.$(date +%s)
fi
