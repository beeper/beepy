#!/bin/sh

sudo_user=${SUDO_USER:-$(whoami)}
sudo_user_home=$(eval echo ~$sudo_user)
echo "$sudo_user_home/.hushlogin"

mv -f /etc/motd /etc/motd.backup.$(date +%s)
mv -f /etc/issue /etc/issue.backup.$(date +%s)
