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
git clone https://github.com/w4ilun/Sharp-Memory-LCD-Kernel-Driver.git || { script_error "Error: Failed to clone display driver repository."; }
cd ~/Sharp-Memory-LCD-Kernel-Driver

make || { script_error "Error: Failed to compile display driver."; }
sudo make modules_install || { script_error "Error: Failed to install display driver."; }
sudo depmod -A || { echo "Error: Failed to update module dependencies."; exit 1; }
echo 'sharp' | sudo tee -a /etc/modules
dtc -@ -I dts -O dtb -o sharp.dtbo sharp.dts || { script_error "Error: Failed to compile device tree."; }
sudo cp sharp.dtbo /boot/overlays
echo -e "framebuffer_width=400\nframebuffer_height=240\ndtoverlay=sharp" | sudo tee -a /boot/config.txt
sudo sed -i ' 1 s/.*/& fbcon=map:10 fbcon=font:VGA8x16/' /boot/cmdline.txt || { script_error "Error: Failed to modify cmdline.txt."; }

echo "Compiling and installing keyboard device driver..."
cd ~/
git clone https://github.com/sqfmi/bbqX0kbd_driver.git || { script_error "Error: Failed to clone keyboard driver repository."; }
cd ~/bbqX0kbd_driver
./installer.sh --BBQ20KBD_TRACKPAD_USE BBQ20KBD_TRACKPAD_AS_KEYS --BBQX0KBD_INT BBQX0KBD_USE_INT || { script_error "Error: Failed to install keyboard device driver.";}

echo "Cleaning up files..."
cd ~/
rm -rf ~/bbqX0kbd_driver
rm -rf ~/Sharp-Memory-LCD-Kernel-Driver

echo "Rebooting..."
sudo shutdown -r now || { echo "Error: Failed to reboot."; exit 1; }

function cleanup () {
  echo "Cleaning up files..."
  cd ~/
  rm -rf ~/bbqX0kbd_driver
  rm -rf ~/Sharp-Memory-LCD-Kernel-Driver
}

function script_error () {
  echo "$1"
  cleanup
  exit 1;
}
