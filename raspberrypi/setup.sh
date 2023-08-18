#!/bin/bash
set -e

echo "Enabling I2C, SPI, and Console Auto login..."
sudo raspi-config nonint do_i2c 0 || { echo "Error: Failed to enable I2C."; exit 1; }
sudo raspi-config nonint do_spi 0 || { echo "Error: Failed to enable SPI."; exit 1; }
sudo raspi-config nonint do_boot_behaviour B2 || { echo "Error: Failed to enable Console Auto login."; exit 1; }

echo "Updating and installing dependencies..."
sudo apt-get -y install git raspberrypi-kernel-headers < "/dev/null" || { echo "Error: Failed to install dependencies."; exit 1; }

echo "Compiling and installing display driver..."
cd ~/
git clone https://github.com/sqfmi/Sharp-Memory-LCD-Kernel-Driver.git || { echo "Error: Failed to clone display driver repository."; exit 1; }
cd ~/Sharp-Memory-LCD-Kernel-Driver
make || { echo "Error: Failed to compile display driver."; exit 1; }
sudo make install || { echo "Error: Failed to install display driver."; exit 1; }
# sudo depmod -A || { echo "Error: Failed to update module dependencies."; exit 1; }
# echo 'sharp' | sudo tee -a /etc/modules
# dtc -@ -I dts -O dtb -o sharp.dtbo sharp.dts || { echo "Error: Failed to compile device tree."; exit 1; }
# sudo cp sharp.dtbo /boot/overlays
echo -e "framebuffer_width=400\nframebuffer_height=240" | sudo tee -a /boot/config.txt
sudo sed -i ' 1 s/.*/& fbcon=map:10 fbcon=font:VGA8x16/' /boot/cmdline.txt || { echo "Error: Failed to modify cmdline.txt."; exit 1; }

echo "Compiling and installing keyboard device driver..."
cd ~/
git clone https://github.com/sqfmi/bbqX0kbd_driver.git || { echo "Error: Failed to clone keyboard driver repository."; exit 1; }
cd ~/bbqX0kbd_driver
make || { echo "Error: Failed to compile display driver."; exit 1; }
sudo make install || { echo "Error: Failed to install display driver."; exit 1; }

echo "Load keymap on start up..."
sudo chmod +x ./init/S01beepykbd
sudo mv ./init/S01beepykbd /etc/init.d/
sudo update-rc.d S01beepykbd defaults

echo "Rebooting..."
sudo shutdown -r now || { echo "Error: Failed to reboot."; exit 1; }
