#!/bin/sh

sudo sed -i ' 1 s/.*/& vt.global_cursor_default=0/' /boot/cmdline.txt || { echo "Error: Failed to modify cmdline.txt."; exit 1; }


