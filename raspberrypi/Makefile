SHELL := /bin/bash

# Variables
IMAGE_URL = https://downloads.raspberrypi.org/raspios_lite_armhf_latest
IMAGE_NAME = raspios_lite_armhf
IMAGE_EXT = .img
KERNEL_URL = https://github.com/raspberrypi/firmware/raw/master/boot/kernel.img
KERNEL_NAME = kernel.img
DTB_URL = https://github.com/raspberrypi/firmware/raw/master/boot/bcm2708-rpi-zero-w.dtb
DTB_NAME = bcm2708-rpi-zero-w.dtb
PLAYBOOK = playbook.yml

.PHONY: all
all: check-dependencies download-image extract-image resize-image download-kernel download-dtb boot-qemu run-playbook ## Run all steps

.PHONY: check-dependencies
check-dependencies: ## Check required dependencies
	@command -v qemu-system-arm > /dev/null 2>&1 || { echo >&2 "QEMU is not installed. Aborting."; exit 1; }
	@command -v xz > /dev/null 2>&1 || { echo >&2 "Xz is not installed. Aborting."; exit 1; }
	@command -v wget > /dev/null 2>&1 || { echo >&2 "Wget is not installed. Aborting."; exit 1; }
	@command -v ansible-playbook > /dev/null 2>&1 || { echo >&2 "Ansible-playbook is not installed. Aborting."; exit 1; }

.PHONY: download-image
download-image: ## Download Raspberry Pi OS image
	@if [ ! -f $(IMAGE_NAME)$(IMAGE_EXT) ]; then \
		echo "Downloading Raspberry Pi OS image..."; \
		wget $(IMAGE_URL) -O $(IMAGE_NAME)$(IMAGE_EXT).xz; \
	fi

.PHONY: extract-image
extract-image: ## Extract the downloaded image
	@if [ ! -f $(IMAGE_NAME)$(IMAGE_EXT) ]; then \
		echo "Extracting Raspberry Pi OS image..."; \
		xz -v -d -k -f $(IMAGE_NAME)$(IMAGE_EXT).xz; \
	fi

.PHONY: resize-image
resize-image: ## Resize the image
	@echo "Resizing the Raspberry Pi OS image..."
	@qemu-img resize -f raw $(IMAGE_NAME).img 4096M

.PHONY: download-kernel
download-kernel: ## Download a compatible kernel for QEMU
	@if [ ! -f $(KERNEL_NAME) ]; then \
		echo "Downloading Raspberry Pi OS kernel..."; \
		wget $(KERNEL_URL) -O $(KERNEL_NAME); \
	fi

.PHONY: download-dtb
download-dtb: ## Download the compatible Device Tree Blob (DTB)
	@if [ ! -f $(DTB_NAME) ]; then \
		echo "Downloading Raspberry Pi OS dtb..."; \
		wget $(DTB_URL) -O $(DTB_NAME); \
	fi

.PHONY: mount-image
mount-image: ## Mount the Raspberry Pi OS image
	@echo "Mounting the Raspberry Pi OS image..."
	@sudo mkdir -p /mnt/rpi
	@sudo mount -o loop,offset=272629760 $(IMAGE_NAME).img /mnt/rpi

.PHONY: unmount-image
unmount-image: ## Unmount the Raspberry Pi OS image
	@echo "Unmounting the Raspberry Pi OS image..."
	@if mountpoint -q /mnt/rpi; then \
		sudo umount /mnt/rpi; \
	fi
	@sudo rmdir /mnt/rpi

.PHONY: copy-scripts
copy-scripts: mount-image ## Copy the setup and optimization scripts to the image
	@echo "Copying setup and optimization scripts to the image..."
	@sudo cp setup.sh /mnt/rpi/root/
	@sudo cp optimize_boot.sh /mnt/rpi/root/
	@echo '#!/bin/bash' | sudo tee /mnt/rpi/etc/init.d/boot-start.sh
	@echo 'date +%s > /boot/start.txt' | sudo tee -a /mnt/rpi/etc/init.d/boot-start.sh
	@echo '#!/bin/bash' | sudo tee /mnt/rpi/etc/init.d/boot-end.sh
	@echo 'date +%s > /boot/end.txt' | sudo tee -a /mnt/rpi/etc/init.d/boot-end.sh
	@sudo chmod +x /mnt/rpi/etc/init.d/boot-start.sh
	@sudo chmod +x /mnt/rpi/etc/init.d/boot-end.sh
	@if [ ! -L /mnt/rpi/etc/rcS.d/S01boot-start.sh ]; then \
		sudo ln -s ../init.d/boot-start.sh /mnt/rpi/etc/rcS.d/S01boot-start.sh; \
	fi
	@if [ ! -L /mnt/rpi/etc/rcS.d/S99boot-end.sh ]; then \
		sudo ln -s ../init.d/boot-end.sh /mnt/rpi/etc/rcS.d/S99boot-end.sh; \
	fi
	@make unmount-image


.PHONY: boot-qemu
boot-qemu: copy-scripts ## Boot the image in QEMU
	@echo "Booting Raspberry Pi OS in QEMU..."
	# @qemu-system-arm -machine raspi0 -kernel $(KERNEL_NAME) -dtb $(DTB_NAME) -netdev user,id=net0,hostfwd=tcp::5022-:22 -device usb-net,netdev=net0 -no-reboot -append "earlycon=pl011,0x20201000 console=ttyAMA0,115200  dwc_otg.fiq_fsm_enable=0 dwc_otg.fiq_enable=0 dwc_otg.nak_holdoff=0 root=/dev/mmcblk0p2 initcall_blacklist=bcm2835_pm_driver_init arm_boost=1 rootwait" -drive "file=$(IMAGE_NAME).img,format=raw,index=0,media=disk" --nographic
	@qemu-system-arm -machine raspi0 -kernel $(KERNEL_NAME) -dtb $(DTB_NAME) -netdev user,id=net0,hostfwd=tcp::5022-:22 -device usb-net,netdev=net0 -no-reboot -append "earlycon=pl011,0x20201000 console=ttyAMA0,115200  dwc_otg.fiq_fsm_enable=0 dwc_otg.fiq_enable=0 dwc_otg.nak_holdoff=0 root=/dev/mmcblk0p2 initcall_blacklist=bcm2835_pm_driver_init arm_boost=1 rootwait init=/etc/init.d/boot-start.sh" -drive "file=$(IMAGE_NAME).img,format=raw,index=0,media=disk" --nographic

.PHONY: run-playbook
run-playbook: ## Run the Ansible playbook
	@echo "Running the Ansible playbook..."
	@ansible-playbook $(PLAYBOOK)

.PHONY: help
help: ## Display this help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)