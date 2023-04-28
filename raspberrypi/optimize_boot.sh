#!/bin/sh
#This script reduces boot times from 60s to 19s on the RPi0w

if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo "Not running as root"
    exit
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
systemctl disable dhcpcd
systemctl disable systemd-timesyncd
systemctl disable polkit
systemctl disable ModemManager
systemctl disable wpa_supplicant
systemctl disable networking
systemctl disable avahi-daemon
systemctl disable dphys-swapfile
systemctl disable keyboard-setup
systemctl disable apt-daily
systemctl disable raspi-config
