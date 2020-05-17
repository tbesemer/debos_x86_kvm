#!/bin/bash

# Define the packages to install onto the Base RFS.
#
PACKAGES=netbase
PACKAGES+=,net-tools
PACKAGES+=,ifupdown
PACKAGES+=,isc-dhcp-client
PACKAGES+=,inetutils-ping
PACKAGES+=,less
PACKAGES+=,locales-all
PACKAGES+=,vim
PACKAGES+=,sudo
PACKAGES+=,openssh-server
PACKAGES+=,systemd-sysv
PACKAGES+=,procps
PACKAGES+=,util-linux
PACKAGES+=,initramfs-tools


#  Key variables for proper opration.
#
#  We assume that ROOT_DIR and IMAGES_DIR are set, and if not,
#  then we must error out.
#
if [ ! -d ${ROOT_DIR}/images ] 
then
   echo "$0: ERROR: ROOT_DIR/images missing, FAIL"
   echo "$0: ROOT_DIR == ${ROOT_DIR}"
   echo "$0: IMAGES_DIR ==${IMAGES_DIR}"
   exit 1
fi

#  Confirm scripts are in BIN_DIR
#
if [ ! -f ${BIN_DIR}/debos_rfs_ops ]
then
   echo "$0: Missing BIN_DIR/debos_rfs_ops missing, FAIL"
   exit 1
fi

ROOTFS_PATH=${IMAGES_DIR}/${ROOTFS_NAME}

#  Helper functions for RFS Generation.
#
source ${BIN_DIR}/debos_rfs_ops

#  Validate that our EUID is root, either through
#  running as root, or through sudo.
#
if [ $EUID -ne 0 ]
then
    echo "$0: EUID == $EUID, please run as EUID 0"
    exit 1
fi

#  Set CTL C handler, we need to exit clean,
#  without all mount points unmounted.
#
echo "$0 Setting CTL C handler"
trap ctl_c_handler SIGINT

#  Begin RFS Generation Logic.
#
echo "$0: Installing Base"
do_base_install
if [ $? -ne 0 ]
then
    echo "$0: do_base_install FAILED"
    exit 1
fi

echo "$0: Mounting for Package Install"
do_mount
if [ $? -ne 0 ]
then
    echo "$0: do_mount FAILED"
    exit 1
fi

echo "$0: Doing Package Install"
do_package_install $PACKAGES
if [ $? -ne 0 ]
then
    echo "$0: do_package_install FAILED"
    do_unmount;
    exit 1
fi

echo "$0: Installing Kernel"
pushd $ROOTFS_PATH
tar xf ${IMAGES_DIR}/os_release.tar
popd
chroot ${ROOTFS_PATH} sh -c "update-initramfs -c -k 4.19.118+ ;"

echo "$0: Unmounting after Package Install"
do_unmount
if [ $? -ne 0 ]
then
    echo "$0: do_unmount FAILED"
    exit 1
fi

echo "$0: Root FS Created"
exit 0
