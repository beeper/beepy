## Getting Started

1. Use the [Raspberry Pi Imager tool](https://www.raspberrypi.com/software/) to flash an SD card with the latest image
    - Choose 32-bit if you are using Pi Zero
    - Choose the Lite image if you don't need the full desktop environment and other apps
    - Click the gear icon to also setup WiFi and SSH

2. SSH into the pi and run ```sudo raspi-config```
    - Select ```Interface Options``` and enable I2C and SPI
    - Select ```System Options``` -> ```Boot / Auto Login``` -> ```Console``` if you are using an image with the full Desktop environment

## Display

3. Clone the display driver [repo](https://github.com/kylehawes/Sharp-Memory-LCD-Kernel-Driver) and follow the instructions to compile
    - In the [Device Tree Overlay](https://github.com/kylehawes/Sharp-Memory-LCD-Kernel-Driver#compileinstall-the-driver) step, use the [sharp.dts](sharp.dts) file for the correct pin mapping
    - In ```/boot/cmdline.txt``` you can also append ```fbcon=font:VGA8x8``` to choose the preferred font and size. See [docs](https://www.kernel.org/doc/Documentation/fb/fbcon.txt) for all the options


## Keyboard

### Firmware
The keyboard firmware was built using this [repo](https://github.com/solderparty/i2c_puppet). You will have to replace the pin mapping header file under ```/boards``` with [bbq20kbd_breakout.h](../bbq20kbd_breakout.h).

Hold the "end call" button during power cycle to put the keyboard MCU into bootloader mode, it will now appear as a USB storage device and you can drag'n'drop the new firmware (\*.uf2) into the drive and it will reboot with the new firmware.

### Software
You can read the key strokes from the keyboard over i2c using this [library](https://github.com/solderparty/arturo182_CircuitPython_BBQ10Keyboard). Running the modified test file [../bbq10keyboard_simpletest.py](bbq10keyboard_simpletest.py) will also cycle through the RGB LEDs.
