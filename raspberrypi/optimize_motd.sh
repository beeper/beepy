#!/bin/sh

#!/bin/sh

default_motd_sha256="a378977155fb42bb006496321cbe31f74cbda803c3f6ca590f30e76d1afad921"
local_sha256=$(sha256sum /etc/motd | awk '{print $1}')

if [ "$default_motd_sha256" = "$local_sha256" ]; then
  mv /etc/motd /etc/motd.default.backup
fi
