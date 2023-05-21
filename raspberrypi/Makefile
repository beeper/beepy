SHELL := /bin/bash

# Variables
IMAGE_URL = https://downloads.raspberrypi.org/raspios_lite_armhf_latest
IMAGE_NAME = raspios_lite_armhf
IMAGE_EXT = .xz
KERNEL_URL = https://github.com/raspberrypi/firmware/raw/master/boot/kernel.img
KERNEL_NAME = kernel.img
DTB_URL = https://github.com/raspberrypi/firmware/raw/master/boot/bcm2708-rpi-zero-w.dtb
DTB_NAME = bcm2708-rpi-zero-w.dtb
PLAYBOOK = playbook.yml

.PHONY: all
all: check-dependencies download-image extract-image rename-image resize-image download-kernel download-dtb boot-qemu run-playbook ## Run all steps

.PHONY: check-dependencies
check-dependencies: ## Check required dependencies
	@command -v qemu-system-arm > /dev/null 2>&1 || { echo >&2 "QEMU is not installed. Aborting."; exit 1; }
	@command -v xz > /dev/null 2>&1 || { echo >&2 "Xz is not installed. Aborting."; exit 1; }
	@command -v wget > /dev/null 2>&1 || { echo >&2 "Wget is not installed. Aborting."; exit 1; }
	@command -v ansible-playbook > /dev/null 2>&1 || { echo >&2 "Ansible-playbook is not installed. Aborting."; exit 1; }

.PHONY: download-image
download-image: ## Download Raspberry Pi OS image
	@if [ ! -f $(IMAGE_NAME)$(IMAGE_EXT) ]; then \
		wget $(IMAGE_URL) -O $(IMAGE_NAME)$(IMAGE_EXT); \
	fi

.PHONY: extract-image
extract-image: ## Extract the downloaded image
	@xz -d -k -f $(IMAGE_NAME)$(IMAGE_EXT)

.PHONY: rename-image
rename-image: ## Rename the extracted image
	@mv $(IMAGE_NAME) $(IMAGE_NAME).img

.PHONY: resize-image
resize-image: ## Resize the image
	@qemu-img resize -f raw $(IMAGE_NAME).img 4096M

.PHONY: download-kernel
download-kernel: ## Download a compatible kernel for QEMU
	@wget $(KERNEL_URL) -O $(KERNEL_NAME)

.PHONY: download-dtb
download-dtb: ## Download the compatible Device Tree Blob (DTB)
	@wget $(DTB_URL) -O $(DTB_NAME)

.PHONY: boot-qemu
boot-qemu: ## Boot the image in QEMU
	@qemu-system-arm -machine raspi0 -kernel $(KERNEL_NAME) -dtb $(DTB_NAME) -netdev user,id=net0,hostfwd=tcp::5022-:22 -device usb-net,netdev=net0 -no-reboot -append "earlycon=pl011,0x20201000 console=ttyAMA0,115200  dwc_otg.fiq_fsm_enable=0 dwc_otg.fiq_enable=0 dwc_otg.nak_holdoff=0 root=/dev/mmcblk0p2 initcall_blacklist=bcm2835_pm_driver_init arm_boost=1 rootwait" -drive "file=$(IMAGE_NAME).img,format=raw,index=0,media=disk" --nographic

.PHONY: run-playbook
run-playbook: ## Run the Ansible playbook
	@ansible-playbook $(PLAYBOOK)

.PHONY: help
help: ## Display this help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
