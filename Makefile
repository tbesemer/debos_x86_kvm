export ROOT_DIR := $(shell pwd)
export IMAGES_DIR := ${ROOT_DIR}/images
export BIN_DIR := ${ROOT_DIR}/bin
export CONFIG_DIR := ${ROOT_DIR}/config
export ROOTFS_OVERLAY_DIR := ${ROOT_DIR}/rootfs_overlay
export ROOTFS_NAME := kvm-x86-rootfs
export QCOW_ROOTFS_NAME := qcow_mnt

.PHONY: all
all: build_template_rfs prepare_qcow_image

.PHONY: build_template_rfs
build_template_rfs:
	sudo -E bin/do_generate_base_x86.sh

.PHONY: prepare_qcow_image
prepare_qcow_image:
	bin/do_prepare_qcow.sh

.PHONY: mount_qcow_image
mount_qcow_image:
	bin/do_mount_qcow.sh

.PHONY: unmount_qcow_image
unmount_qcow_image:
	bin/do_unmount_qcow.sh

.PHONY: clean_template_rfs
clean_template_rfs:
	sudo -E bin/do_clean_base_x86.sh
