#!/bin/sh

if systemctl list-units --full -all | grep -q "disable-cursor-blink.service"; then
  systemctl disable disable-cursor-blink.service
fi

rm /etc/systemd/system/disable-cursor-blink.service
systemctl daemon-reload
