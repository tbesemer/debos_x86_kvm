#!/bin/bash

if [ -z "$ROOT_DIR" ]
then
    echo "$0:ROOT_DIR not set"
    ROOT_DIR=`pwd`
else
    echo "$0: Using ROOT_DIR [$ROOT_DIR]"
fi

if [ -z "$NPROCS" ]
then
    echo "$0: NPROCS not set, setting to 1"
    NPROCS=1
else
    echo "$0: NPROCS == $NPROCS"
fi

CONFIG_DIR=$ROOT_DIR/config
CONFIG_FILE=defconfig_linux-4.19.118+
BUILD_DIR_NAME="linux_build"
IMAGES_DIR="$ROOT_DIR"/images
BOOT_ROOT_DIR="$IMAGES_DIR"/boot_root
BUILD_DIR="$IMAGES_DIR"/"$BUILD_DIR_NAME"
INSTALL_MOD_PATH_ROOT="$BOOT_ROOT_DIR"

#  Check to see if ~/images/os_release.tar exists, if so, don't
#  run the long build - if people want to rebuild, they have to
#  clean things up by hand, and do what they want to do by hand.
#
if [ -f $IMAGES_DIR/os_release.tar ]
then
    echo "$0: ~/images/os_release.tar exists, not building"
    echo "=========>    Please remove if you want a rebuild"
    exit 0
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

mkdir -p $BOOT_ROOT_DIR
if [ $? -ne 0 ]
then
    echo "$0: Unable to create BOOT_ROOT_DIR [$BOOT_ROOT_DIR]"
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
wget https://deb.debian.org/debian/pool/main/l/linux/linux_4.19.118.orig.tar.xz
git clone -b buster --single-branch https://salsa.debian.org/kernel-team/linux.git

# Begin the build.
#
pushd linux
debian/rules orig

echo "Instalilng Config with: cp $CONFIG_DIR/$CONFIG_FILE .config"
cp $CONFIG_DIR/$CONFIG_FILE .config

make ARCH=x86_64 oldconfig
make clean
make -j $NPROCS ARCH=x86_64 bzImage
make -j $NPROCS ARCH=x86_64 modules

make ARCH=x86_64  modules_install INSTALL_MOD_PATH=$INSTALL_MOD_PATH_ROOT
mkdir -p $BOOT_ROOT_DIR/boot
cp arch/x86/boot/bzImage  $BOOT_ROOT_DIR/boot/vmlinuz-4.19.118+
cp .config  $BOOT_ROOT_DIR/boot/config-4.19.118+
pushd $BOOT_ROOT_DIR
ln -fs boot/vmlinuz-4.19.118+ vmlinuz
ln -fs boot/initrd.img-4.19.118+ initrd.img
tar cf $IMAGES_DIR/os_release.tar .
popd

popd

