#!/bin/bash
set -e

echo "Switching to root user..."
sudo -i

echo "Enabling I2C, SPI, and Console Auto login..."
raspi-config nonint do_i2c 0 || { echo "Error: Failed to enable I2C."; exit 1; }
raspi-config nonint do_spi 0 || { echo "Error: Failed to enable SPI."; exit 1; }
raspi-config nonint do_boot_behaviour B2 || { echo "Error: Failed to enable Console Auto login."; exit 1; }

echo "Updating and installing dependencies..."
apt-get -y update || { echo "Error: Failed to update apt-get."; exit 1; }
apt-get -y upgrade < "/dev/null" || { echo "Error: Failed to upgrade apt-get."; exit 1; }
apt-get -y install git raspberrypi-kernel-headers < "/dev/null" || { echo "Error: Failed to install dependencies."; exit 1; }

echo "Compiling and installing display driver..."
git clone https://github.com/w4ilun/Sharp-Memory-LCD-Kernel-Driver.git || { echo "Error: Failed to clone display driver repository."; exit 1; }
cd Sharp-Memory-LCD-Kernel-Driver
make || { echo "Error: Failed to compile display driver."; exit 1; }
make modules_install || { echo "Error: Failed to install display driver."; exit 1; }
depmod -A || { echo "Error: Failed to update module dependencies."; exit 1; }
echo sharp >> /etc/modules
dtc -@ -I dts -O dtb -o sharp.dtbo sharp.dts || { echo "Error: Failed to compile device tree."; exit 1; }
sudo cp sharp.dtbo /boot/overlays
echo -e "framebuffer_width=400\nframebuffer_height=240\ndtoverlay=sharp" > /boot/config.txt
sed -i ' 1 s/.*/& fbcon=map:10 fbcon=font:VGA8x8/' /boot/cmdline.txt || { echo "Error: Failed to modify cmdline.txt."; exit 1; }

echo "Compiling and installing keyboard device driver..."
git clone https://github.com/wallComputer/bbqX0kbd_driver.git || { echo "Error: Failed to clone keyboard driver repository."; exit 1; }
cd bbqX0kbd_driver
./installer.sh --BBQ20KBD_TRACKPAD_USE BBQ20KBD_TRACKPAD_AS_KEYS --BBQX0KBD_INT BBQX0KBD_USE_INT || { echo "Error: Failed to install keyboard device driver."; exit 1; }

echo "Rebooting..."
shutdown -r now || { echo "Error: Failed to reboot."; exit 1; }
