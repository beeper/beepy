#!/bin/sh

cat <<EOL > "/etc/systemd/system/disable-cursor-blink.service"
[Unit]
Description=Disable cursor blink on Linux console
DefaultDependencies=no
Before=sysinit.target

[Service]
Type=oneshot
ExecStart=/bin/sh -c "echo 0 > /sys/class/graphics/fbcon/cursor_blink"

[Install]
WantedBy=sysinit.target
EOL

systemctl daemon-reload
systemctl enable disable-cursor-blink.service
systemctl start disable-cursor-blink.service
