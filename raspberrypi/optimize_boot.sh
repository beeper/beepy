#!/bin/sh
#This script reduces boot times from 60s to 19s on the RPi0w

#shellcheck disable=SC2312
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root"
    exit 1
fi

echo '
[all]
initial_turbo=30
disable_splash=1
dtoverlay=disable-bt
boot_delay=0
' >> /boot/config.txt

sed -i '1s/$/ loglevel=3 quiet logo.nologo consoleblank=0 fastboot/' /boot/cmdline.txt

systemctl disable triggerhappy
systemctl disable systemd-timesyncd
systemctl disable polkit
systemctl disable ModemManager
systemctl disable avahi-daemon
systemctl disable dphys-swapfile
systemctl disable keyboard-setup
systemctl disable apt-daily
systemctl disable raspi-config
