#!/bin/sh

set -u
set -e

# Add an autologin console on tty1
if [ -e ${TARGET_DIR}/etc/inittab ]; then
    grep -qE '^tty1::' ${TARGET_DIR}/etc/inittab || \
	sed -i '/GENERIC_SERIAL/a\
tty1::respawn:-/bin/sh' ${TARGET_DIR}/etc/inittab
fi

# Auto launch gomuks on login on tty1
echo '
if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then
gomuks -s
fi' >> ${TARGET_DIR}/etc/profile