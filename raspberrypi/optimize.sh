#!/bin/sh

curl -s "https://raw.githubusercontent.com/dezren39-dev/beepy/optimize/raspberrypi/optimize-startup.sh" | bash
curl -s "https://raw.githubusercontent.com/dezren39-dev/beepy/optimize/raspberrypi/optimize-power.sh" | bash
curl -s "https://raw.githubusercontent.com/dezren39-dev/beepy/optimize/raspberrypi/optimize-shutdown.sh" | bash
