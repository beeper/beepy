## Getting Started

1. Use the [Raspberry Pi Imager tool](https://www.raspberrypi.com/software/) to flash an SD card with the latest image
    - Choose the Raspberry Pi OS Lite (32-bit) image
    - Click the gear icon to also setup WiFi and SSH

2. SSH into the pi and run ```sudo raspi-config```
    - Select ```Interface Options``` and enable I2C and SPI
    - Select ```System Options``` -> ```Boot / Auto Login``` -> ```Console AutoLogin```

### Display

3. Install the raspberry pi kernel headers
    - ```sudo apt-get install raspberrypi-kernel-headers```
4. Copy over these files to a dir on the pi [sharp.c](./sharp.c), [sharp.dts](./sharp.dts), [Makefile](./Makefile) and compile the driver
    - run ```make```
    - then run ```sudo make modules_install```
    - then run ```sudo depmod -A```
    - then run ```echo sharp >> /etc/modules```
5. Compile/install the device tree overlay
    - run ```dtc -@ -I dts -O dtb -o sharp.dtbo sharp.dts```
    - then run ```sudo cp sharp.dtbo /boot/overlays```
    - add ```dtoverlay=sharp``` to the end of ```/boot/config.txt```
6. Configure the console on display
    - In ```/boot/cmdline.txt```, append ```fbcon=map:10```, you can also append ```fbcon=font:VGA8x8``` to choose the preferred font and size. See [docs](https://www.kernel.org/doc/Documentation/fb/fbcon.txt) for all the options
    - Set ```framebuffer_width=400``` and ```framebuffer_height=240``` in ```/boot/config.txt```
7. Reboot and the display should be working


### Keyboard

### Firmware
The keyboard firmware was built using this [repo](https://github.com/solderparty/i2c_puppet). You will have to replace the pin mapping header file under ```/boards``` with [bbq20kbd_breakout.h](../bbq20kbd_breakout.h).

Hold the "end call" button during power cycle to put the keyboard MCU into bootloader mode, it will now appear as a USB storage device and you can drag'n'drop the new firmware (\*.uf2) into the drive and it will reboot with the new firmware.

### Software
Follow the instructions here to install the keyboard driver https://github.com/wallComputer/bbqX0kbd_driver/
