#!/bin/bash

apt update
apt install -y build-essential wget device-tree-compiler git
cd ~ 
wget https://raw.githubusercontent.com/beeper/beeper-beeper/main/u-boot.zip 
unzip u-boot.zip

# install lcd driver
cd ~
git clone https://github.com/billylindeman/Sharp-Memory-LCD-Kernel-Driver.git
cd Sharp-Memory-LCD-Kernel-Driver/
make
make modules_install
depmod -A
echo sharp >> /etc/modules
dtc -@ -I dts -O dtb -o sharp.dtbo sharp-radxa-zero.dts
cp sharp.dtbo /boot/dtbs/5.10.69-12-amlogic-g98700611d064/amlogic/overlay

# install keyboard driver
cd ~
git clone https://github.com/billylindeman/bbq10kbd-kernel-driver.git
cd bbq10kbd-kernel-driver/
make modules modules_install
depmod -A
echo bbq10kbd >> /etc/modules
dtc -@ -I dts -O dtb -o bbq10kbd-radxa-zero.dtbo dts/bbq10kbd-radxa-zero.dts
cp bbq10kbd-radxa-zero.dtbo /boot/dtbs/5.10.69-12-amlogic-g98700611d064/amlogic/overlay/

cat >> /boot/uEnv.txt << EOF

overlays=meson-g12a-uart-ao-a-on-gpioao-0-gpioao-1 meson-g12a-spi-spidev sharp meson-g12a-i2c-ee-m3-gpioa-14-gpioa-15 bbq10kbd-radxa-zero
param_spidev_spi_bus=1
param_spidev_max_freq=10000000
extraargs=fbcon=map:0 fbcon=font:VGA8x8 framebuffer_width=400 framebuffer_height=240
EOF

cat > /etc/default/console-setup << EOF

# Consult the console-setup(5) manual page.
ACTIVE_CONSOLES="/dev/tty[1-6]"
CHARMAP="UTF-8"
CODESET="Lat15"
FONTFACE="Fixed"
FONTSIZE="8x14"
VIDEOMODE=

EOF

cd ~/u-boot-radxa-zero/
./setup.sh update_bootloader /dev/mmcblk1 amlogic
sed -e s@/amlogic@@g -i /boot/extlinux/extlinux.conf

echo "Set up complete" 
echo "Please shutdown, then connect radxa to Beeper PCB and plug in to bottom USB C port. Then switch on the device!"
