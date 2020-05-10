export ROOT_DIR := $(shell pwd)
export IMAGES_DIR := ${ROOT_DIR}/images
export BIN_DIR := ${ROOT_DIR}/bin

.PHONY: build_template_rfs
build_template_rfs:
	sudo -E bin/do_generate_base_x86.sh
