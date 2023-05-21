SHELL := /bin/bash

# Variables
IMAGE_URL = https://downloads.raspberrypi.org/raspios_lite_armhf_latest
IMAGE_NAME = raspios_lite_armhf
IMAGE_EXT = .xz
KERNEL_URL = https://github.com/dhruvvyas90/qemu-rpi-kernel/raw/master/kernel-qemu-5.10.63-bullseye
KERNEL_NAME = kernel-qemu
DTB_URL = https://github.com/dhruvvyas90/qemu-rpi-kernel/raw/master/versatile-pb-bullseye-5.10.63.dtb
DTB_NAME = versatile-pb.dtb
PLAYBOOK = playbook.yml

.PHONY: all
all: check-dependencies download-image extract-image convert-image download-kernel download-dtb boot-qemu run-playbook ## Run all steps

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

.PHONY: convert-image
convert-image: ## Convert the extracted image to QEMU format
	@qemu-img convert -f raw -O qcow2 $(IMAGE_NAME).img $(IMAGE_NAME).qcow2

.PHONY: download-kernel
download-kernel: ## Download a compatible kernel for QEMU
	@wget $(KERNEL_URL) -O $(KERNEL_NAME)

.PHONY: download-dtb
download-dtb: ## Download the compatible Device Tree Blob (DTB)
	@wget $(DTB_URL) -O $(DTB_NAME)

.PHONY: boot-qemu
boot-qemu: ## Boot the image in QEMU
	@qemu-system-arm -kernel $(KERNEL_NAME) -cpu arm1176 -m 256 -M versatilepb -dtb $(DTB_NAME) -serial stdio -append "root=/dev/sda2 panic=1 rootfstype=ext4 rw" -hda $(IMAGE_NAME).qcow2 -net nic -net user,hostfwd=tcp::5022-:22


.PHONY: run-playbook
run-playbook: ## Run the Ansible playbook
	@ansible-playbook $(PLAYBOOK)

.PHONY: help
help: ## Display this help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)