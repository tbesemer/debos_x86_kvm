export ROOT_DIR := $(shell pwd)
export IMAGES_DIR := ${ROOT_DIR}/images
export BIN_DIR := ${ROOT_DIR}/bin
export ROOTFS_NAME := kvm-x86-rootfs

.PHONY: build_template_rfs
build_template_rfs:
	sudo -E bin/do_generate_base_x86.sh

.PHONY: clean_template_rfs
clean_template_rfs:
	sudo -E bin/do_clean_base_x86.sh
