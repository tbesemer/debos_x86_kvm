#!/bin/bash

# Basic Debian 9 Machine Setup for KVM.
#
#  This shows packages needed to get KVM going.
#
#  From:
#    https://www.cyberciti.biz/faq/install-kvm-server-debian-linux-9-headless-server/

sudo apt install -y qemu-kvm libvirt-clients libvirt-daemon-system bridge-utils libguestfs-tools genisoimage virtinst libosinfo-bin

#  As part of NBD for building QCOW images:
#
sudo apt-get install -y nbd-server nbd-client qemu-utils

# Install Virtual Machine Manager
#
sudo apt-get install virt-manager

# Install debootstrap
#
sudo apt-get install debootstrap
