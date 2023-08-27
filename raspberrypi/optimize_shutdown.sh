#!/bin/sh

echo "kernel.printk = -1 -1 -1 -1" > "/etc/sysctl.d/20-quiet-printk.conf" || { echo "Error: Create '/etc/sysctl.d/20-quiet-printk.conf'."; exit 1; }
