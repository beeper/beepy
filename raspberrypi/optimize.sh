#!/bin/sh

curl -s "https://raw.githubusercontent.com/dezren39-dev/beepy/optimize2/raspberrypi/optimize_boot.sh" | bash
curl -s "https://raw.githubusercontent.com/dezren39-dev/beepy/optimize2/raspberrypi/optimize_motd.sh" | bash
curl -s "https://raw.githubusercontent.com/dezren39-dev/beepy/optimize2/raspberrypi/optimize_power.sh" | bash
curl -s "https://raw.githubusercontent.com/dezren39-dev/beepy/optimize2/raspberrypi/optimize_shutdown.sh" | bash
