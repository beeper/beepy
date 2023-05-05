#!/bin/sh

curl https://buildroot.org/downloads/buildroot-2023.02.tar.xz | tar xJ
mv buildroot-* buildroot

# `make linux-savedefconfig` to save defconfig
# it's stored in buildroot/output/build/linux-custom/defconfig

make -j $(nproc) -C buildroot defconfig BR2_DEFCONFIG=../br_defconfig && \
    make -j $(nproc) -C buildroot && \
    yes | mv -f buildroot/output/images/sdcard.img . && \
    echo "Image built at $(pwd)/sdcard.img"
