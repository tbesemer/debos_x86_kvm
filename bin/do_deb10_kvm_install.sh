#!/bin/bash

#  Debian 10 Install from:
#
#   https://www.linuxtechi.com/install-configure-kvm-debian-10-buster/
#

sudo apt install -y qemu-kvm libvirt-clients libvirt-daemon-system bridge-utils virtinst libvirt-daemon virt-manager

#  As part of NBD for building QCOW images:
#
sudo apt-get install -y nbd-server nbd-client qemu-utils

# Install debootstrap
#
sudo apt-get install debootstrap

