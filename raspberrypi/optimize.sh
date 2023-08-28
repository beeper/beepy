#!/bin/sh

curl -s "https://raw.githubusercontent.com/beeper/beepy/main/raspberrypi/optimize_boot.sh" | bash
curl -s "https://raw.githubusercontent.com/beeper/beepy/main/raspberrypi/disable_motd.sh" | bash
curl -s "https://raw.githubusercontent.com/beeper/beepy/main/raspberrypi/disable_cursor.sh" | bash
curl -s "https://raw.githubusercontent.com/beeper/beepy/main/raspberrypi/optimize_shutdown.sh" | bash
