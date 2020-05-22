export ROOT_DIR := $(shell pwd)
export IMAGES_DIR := ${ROOT_DIR}/images
export BIN_DIR := ${ROOT_DIR}/bin
export CONFIG_DIR := ${ROOT_DIR}/config
export ROOTFS_OVERLAY_DIR := ${ROOT_DIR}/rootfs_overlay
export ROOTFS_NAME := kvm-x86-rootfs
export KERNEL_RELEASE := ${IMAGES_DIR}/os_release.tar
export QCOW_ROOTFS_NAME := qcow_mnt
export NPROCS := $(shell nproc)

# Custom Kernel specific variables
#
export CONFIG_FILE := defconfig_linux-4.19.118+
export BUILD_DIR_NAME := linux_build
export BOOT_ROOT_DIR := ${IMAGES_DIR}/boot_root
export BUILD_DIR := ${IMAGES_DIR}/${BUILD_DIR_NAME}
export INSTALL_MOD_PATH_ROOT := ${BOOT_ROOT_DIR}

.PHONY: all
all: build_template_rfs prepare_qcow_image

.PHONY: build_template_rfs
build_template_rfs:
	sudo -E bin/do_generate_base_x86.sh

.PHONY: prepare_qcow_image
prepare_qcow_image:
	bin/do_prepare_qcow.sh

.PHONY: linux_all
linux_all: fetch_kernel_source linux_defconfig linux linux_install

.PHONY: fetch_kernel_source
fetch_kernel_source:
	bin/do_deb_kernel_pull.sh

.PHONY: linux_defconfig
linux_defconfig:
	cp -p ${CONFIG_DIR}/${CONFIG_FILE} ${BUILD_DIR}/linux/.config
	make ARCH=x86_64 -C ${BUILD_DIR}/linux oldconfig

.PHONY: linux_save_defconfig
linux_save_defconfig:
	cp -p ${BUILD_DIR}/linux/.config ${CONFIG_DIR}/${CONFIG_FILE} 

.PHONY: linux
linux:
	make ARCH=x86_64 -j ${NPROCS} -C ${BUILD_DIR}/linux bzImage
	make ARCH=x86_64 -j ${NPROCS} -C ${BUILD_DIR}/linux modules

.PHONY: linux_install
linux_install:
	bin/do_deb_kernel_install.sh

.PHONY: linux_xconfig
linux_xconfig:
	make ARCH=x86_64 -C ${BUILD_DIR}/linux xconfig

.PHONY: linux_menuconfig
linux_menuconfig:
	make ARCH=x86_64 -C ${BUILD_DIR}/linux menuconfig

.PHONY: mount_qcow_image
mount_qcow_image:
	bin/do_mount_qcow.sh

.PHONY: unmount_qcow_image
unmount_qcow_image:
	bin/do_unmount_qcow.sh

.PHONY: clean_template_rfs
clean_template_rfs:
	sudo -E bin/do_clean_base_x86.sh

.PHONY: help
help:
	@ less README.Makefile
