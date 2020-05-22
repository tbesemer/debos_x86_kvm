#!/bin/bash

#  Simple script to demonstrate pulling and setting
#  up 4.9.118.  Over time, with new releases
#  the Kernel version will change.
#
wget https://deb.debian.org/debian/pool/main/l/linux/linux_4.19.118.orig.tar.xz
git clone -b buster --single-branch https://salsa.debian.org/kernel-team/linux.git
pushd linux
debian/rules orig
popd


