#!/bin/sh

curl -s "https://raw.githubusercontent.com/dezren39-dev/beepy/optimize/raspberrypi/optimize_startup.sh" | bash
curl -s "https://raw.githubusercontent.com/dezren39-dev/beepy/optimize/raspberrypi/optimize_power.sh" | bash
curl -s "https://raw.githubusercontent.com/dezren39-dev/beepy/optimize/raspberrypi/optimize_shutdown.sh" | bash
