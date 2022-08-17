# BeeperHW Board Bringup
## Radxa

### Flash ROM onto SD card

- Download https://github.com/radxa-build/radxa-zero/releases/download/20220801-0213/radxa-zero-ubuntu-focal-server-arm64-20220801-0346-mbr.img.xz 
- Use Etcher to flash image to SD card
- Insert SD card into Radxa, connect USB C cable to jack on bottom of device
- wait 1-2 minutes for first boot 


## Setup Linux 
Now wait wait for it to show up in adb. I had to unplug and plug it back in, then wait several minutes before it showed up. 

```
➜  beeperhw adb devices
List of devices attached
0123456789ABCDEF	device
```


The radxa ubuntu build contains adb support, so we can access the shell with:
```
adb shell
```

##### Enable Root login over SSH
```
sudo vi /etc/ssh/sshd_config
```
Find and change `PermitRootLogin yes`


##### Configure Wifi

```
sudo nmcli radio wifi on
```
```
# nmcli dev wifi list
IN-USE  BSSID              SSID             MODE   CHAN  RATE        SIGNAL  BARS  SECURITY
        6C:CD:D6:D7:82:0F  NETGEAR51        Infra  1     195 Mbit/s  100     ▂▄▆█  WPA2
        6C:CD:D6:D7:82:0E  NETGEAR51-5G     Infra  153   405 Mbit/s  100     ▂▄▆█  WPA2
        BC:A5:11:FA:0D:86  RDMeOffice       Infra  2     130 Mbit/s  85      ▂▄▆█  WPA2
        E4:71:85:30:54:48  The Internet 02  Infra  149   405 Mbit/s  77      ▂▄▆_  WPA1 WPA2
        BC:A5:11:FA:0D:88  RDMeOffice-5G    Infra  149   270 Mbit/s  77      ▂▄▆_  WPA2
        E4:71:85:30:54:4C  The Internet 01  Infra  9     195 Mbit/s  75      ▂▄▆_  WPA1 WPA2
        B0:4E:26:73:48:33  TP-Link_4833     Infra  11    195 Mbit/s  72      ▂▄▆_  WPA1 WPA2
```

```
sudo nmcli dev wifi connect NETGEAR51-5G password "network-password"
```

Give the system a few minutes to connect and sync up.  Ensure datetime is correct / set via NTP before proceeding

##### Build Environment
```
sudo apt install build-essential wget device-tree-compiler
```

##### Sharp LCD Driver 

The main display is driven with this driver: https://github.com/billylindeman/Sharp-Memory-LCD-Kernel-Driver


First compile the kernel modules
```
cd ~
wget -O sharp-lcd.tar.gz https://github.com/billylindeman/Sharp-Memory-LCD-Kernel-Driver/archive/refs/heads/master.tar.gz 
tar zxvf sharp-lcd.tar.gz
cd Sharp-Memory-LCD-Kernel-Driver-master/
make
make modules_install
depmod -A
echo sharp >> /etc/modules
```

Compile device tree overlay, and add it to the /boot

```
dtc -@ -I dts -O dtb -o sharp.dtbo sharp-radxa-zero.dts
cp sharp.dtbo /boot/dtbs/5.10.69-12-amlogic-g98700611d064/amlogic/overlay
```


### Keyboard Driver

```
cd ~
wget -O bbq10kbd.tar.gz https://github.com/billylindeman/bbq10kbd-kernel-driver/archive/refs/heads/master.tar.gz 
tar zxvf bbq10kbd.tar.gz
cd bbq10kbd-kernel-driver/
make modules modules_install
depmod -A
echo bbq10kbd >> /etc/modules
```

```
dtc -@ -I dts -O dtb -o bbq10kbd-radxa-zero.dtbo dts/bbq10kbd-radxa-zero.dts 
cp bbq10kbd-radxa-zero.dtbo /boot/dtbs/5.10.69-12-amlogic-g98700611d064/amlogic/overlay/
```



### Device tree configuration

Edit  `/boot/uEnv.txt` to support spidev, i2c, sharp driver, and bbq10kbd driver

```
overlays=meson-g12a-uart-ao-a-on-gpioao-0-gpioao-1 meson-g12a-spi-spidev sharp meson-g12a-i2c-ee-m3-gpioa-14-gpioa-15 bbq10kbd-radxa-zero
param_spidev_spi_bus=1
param_spidev_max_freq=10000000
extraargs=fbcon=map:0 fbcon=font:VGA8x8 framebuffer_width=400 framebuffer_height=240
```


### Setup Console

The default console charmap has some incorrect characters, so we can reconfigure it by running this as root
```
cat > /etc/default/console-setup << EOF

# Consult the console-setup(5) manual page.
ACTIVE_CONSOLES="/dev/tty[1-6]"
CHARMAP="UTF-8"
CODESET="Lat15"
FONTFACE="Fixed"
FONTSIZE="8x14"
VIDEOMODE=

EOF
```

Now reboot, and you should have a working device!

---- 

## Instructions for Radxa Zero with EMMC
### Dependencies
```
brew install libusb python
pip3 install pyamlboot
```

### Erase MMC
Hold the USB Boot button on the back of the Radxa and plug in the usb-c OTG cable to your computer

```
# First get this aml image 
wget https://dl.radxa.com/zero/images/loader/radxa-zero-erase-emmc.bin
# Flash it to fully erase the eMMC on the Radxa
boot-g12.py ./radxa-zero-erase-emmc.bin
```

### Setup eMMC udisk storage

```
# Download the udisk-storage bootloader
wget https://dl.radxa.com/zero/images/loader/rz-udisk-loader.bin
# Flash bin to get a usb-class-storage access to eMMC
boot-g12.py ./rz-udisk-loader.bin
```

Device should now show up as a usb class storage device.  On mac, this will pop up a dialog saying the disk is uninitialized.. Click Ignore

More info can be found at: https://wiki.radxa.com/Zero/dev/maskrom#Enable_maskrom

### Flash Armbian image
```
# Download ubuntu server image from radxa's github
wget https://github.com/radxa-build/radxa-zero/releases/download/20220801-0213/radxa-zero-ubuntu-focal-server-arm64-20220801-0346-mbr.img.xz

# Decompress image
unxz radxa-zero-ubuntu-focal-server-arm64-20220801-0346-mbr.img.xz

# Flash using dd
sudo dd if=radxa-zero-ubuntu-focal-server-arm64-20220801-0346-mbr.img of=/dev/disk4 bs=1m
```

