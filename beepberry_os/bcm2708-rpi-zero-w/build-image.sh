#!/bin/sh

# Use -N to skip downloads, use -L to skip downloads and clean recompile kernel
if [ "$#" -eq 0 ] || [ "$1" != "-N" ] && [ "$1" != "-L" ]; then
    curl https://buildroot.org/downloads/buildroot-2023.02.tar.xz | tar xJ
    mv buildroot* build
    wget -N https://github.com/raspberrypi/firmware/raw/master/boot/bcm2708-rpi-zero-w.dtb -P build/output/images/
    wget -N https://github.com/raspberrypi/firmware/raw/master/boot/bootcode.bin -P build/output/images/
    wget -N https://github.com/raspberrypi/firmware/raw/master/boot/start_cd.elf -P build/output/images/
    wget -N https://github.com/raspberrypi/firmware/raw/master/boot/fixup_cd.dat -P build/output/images/
fi

ccache make -j $(nproc) -C build defconfig BR2_DEFCONFIG=../br_defconfig && \
if [ "$#" -eq 0 ] || [ "$1" != "-L" ]; then
    ccache make -j $(nproc) -C build linux-dirclean
fi
ccache make -j $(nproc) -C build && \
yes | mv -f build/output/images/sdcard.img . && \
echo "Image built at $(pwd)/sdcard.img"

