#!/bin/sh

curl -s "https://raw.githubusercontent.com/dezren39-dev/beepy/optimize/raspberrypi/optimize_boot.sh" | bash
curl -s "https://raw.githubusercontent.com/dezren39-dev/beepy/optimize/raspberrypi/optimize_power.sh" | bash
curl -s "https://raw.githubusercontent.com/dezren39-dev/beepy/optimize/raspberrypi/optimize_motd.sh" | bash
curl -s "https://raw.githubusercontent.com/dezren39-dev/beepy/optimize/raspberrypi/optimize_motd_uname.sh" | bash
