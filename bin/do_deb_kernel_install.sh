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

mkdir -p $BOOT_ROOT_DIR
if [ $? -ne 0 ]
then
    echo "$0: Unable to create BOOT_ROOT_DIR [$BOOT_ROOT_DIR]"
    exit 1
fi

pushd $BUILD_DIR/linux
if [ $? -ne 0 ]
then
    echo "$0: Unable to pushd into [$BUILD_DIR/linux]"
    exit 1
fi

# Install the Modules.
#
make ARCH=x86_64  modules_install INSTALL_MOD_PATH=$INSTALL_MOD_PATH_ROOT

# Install the core components.
#
mkdir -p $BOOT_ROOT_DIR/boot
cp arch/x86/boot/bzImage  $BOOT_ROOT_DIR/boot/vmlinuz-4.19.118+
cp .config  $BOOT_ROOT_DIR/boot/config-4.19.118+

pushd $BOOT_ROOT_DIR
ln -fs boot/vmlinuz-4.19.118+ vmlinuz
ln -fs boot/initrd.img-4.19.118+ initrd.img
tar cf $KERNEL_RELEASE .
popd

popd

