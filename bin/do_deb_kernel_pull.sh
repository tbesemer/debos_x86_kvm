#!/bin/bash

if [ -z "$ROOT_DIR" ]
then
    echo "$0:ROOT_DIR not set"
    ROOT_DIR=`pwd`
else
    echo "$0: Using ROOT_DIR [$ROOT_DIR]"
fi

echo "ROOT_DIR: $ROOT_DIR"
echo "BUILD_DIR: $BUILD_DIR"
echo "INSTALL_MOD_PATH_ROOT: $INSTALL_MOD_PATH_ROOT"
echo "BOOT_DIR: $BOOT_ROOT_DIR"

mkdir -p $BUILD_DIR
if [ $? -ne 0 ]
then
    echo "$0: Unable to create BUILD_DIR [$BUILD_DIR]"
    exit 1
fi

pushd $BUILD_DIR
if [ $? -ne 0 ]
then
    echo "$0: Unable to pushd into [$BUILD_DIR]"
    exit 1
fi

# Fix these when Upgrading.
#
echo "$0: Pulling Kernel Sources"
wget https://deb.debian.org/debian/pool/main/l/linux/linux_4.19.118.orig.tar.xz
git clone -b buster --single-branch https://salsa.debian.org/kernel-team/linux.git

# Setup Kernel Tree.
#
pushd linux
debian/rules orig
popd

popd

