#!/bin/sh

curl -s "https://raw.githubusercontent.com/beeper/beepy/main/raspberrypi/optimize_boot.sh" | bash
curl -s "https://raw.githubusercontent.com/beeper/beepy/main/raspberrypi/disable_motd.sh" | bash
curl -s "https://raw.githubusercontent.com/beeper/beepy/main/raspberrypi/disable_login_prompt.sh" | bash
curl -s "https://raw.githubusercontent.com/beeper/beepy/main/raspberrypi/disable_cursor_blink.sh" | bash
curl -s "https://raw.githubusercontent.com/beeper/beepy/main/raspberrypi/disable_kernel_logs.sh" | bash
