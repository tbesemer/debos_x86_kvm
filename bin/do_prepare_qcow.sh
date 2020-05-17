#!/bin/bash

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
if [ ! -d ${ROOTFS_PATH} ]
then
   echo "$0: Missing ROOTFS_PATH [$ROOTFS_PATH], FAIL"
   exit 1
fi

#  Helper functions for RFS Generation.
#
source ${BIN_DIR}/debos_rfs_ops

sudo modprobe nbd
if [ $? -ne 0 ]
then
    echo "$0: modprobe ndb Failed"
    exit 1
fi

pushd ${IMAGES_DIR}
if [ $? -ne 0 ]
then
    echo "$0: Can't pushd into IMAGE_DIR [$IMAGES_DIR], Fail"
    exit 1
fi

#  Remove stale image.
#
rm -f qcow2 debian.qcow2
if [ $? -ne 0 ]
then
    echo "$0: Can't remove debian.qcow2, Fail"
    exit 1
fi

qemu-img create -f qcow2 debian.qcow2 20G
if [ $? -ne 0 ]
then
    echo "$0: qemu-img create Failed"
    exit 1
fi

sudo qemu-nbd -c /dev/nbd0 debian.qcow2
if [ $? -ne 0 ]
then
    echo "$0: qemu-ndb on /dev/ndb0 Failed"
    exit 1
fi

sudo sfdisk /dev/nbd0 < ${CONFIG_DIR}/qcow1_part_table.txt
if [ $? -ne 0 ]
then
    echo "$0: sfdisk on /dev/ndb0 Failed"
    sudo qemu-nbd -d /dev/nbd0
    exit 1
fi

sudo mkswap /dev/nbd0p1
if [ $? -ne 0 ]
then
    echo "$0: mkswap on /dev/ndb0p1 Failed"
    sudo qemu-nbd -d /dev/nbd0
    exit 1
fi

sudo mkfs.ext4 /dev/nbd0p2
if [ $? -ne 0 ]
then
    echo "$0: mkfs.ext4 on /dev/ndb0p2 Failed"
    sudo qemu-nbd -d /dev/nbd0
    exit 1
fi

QCOW_ROOTFS_PATH=${IMAGES_DIR}/${QCOW_ROOTFS_NAME}

mkdir -p ${QCOW_ROOTFS_PATH}
if [ $? -ne 0 ]
then
    echo "$0: mkdir on QCOW_ROOTFS_PATH [$QCOW_ROOTFS_PATH] Failed"
    sudo qemu-nbd -d /dev/nbd0
    exit 1
fi

sudo mount /dev/nbd0p2 ${QCOW_ROOTFS_PATH}
if [ $? -ne 0 ]
then
    echo "$0: mount of QCOW_ROOTFS_PATH [$QCOW_ROOTFS_PATH] Failed"
    sudo qemu-nbd -d /dev/nbd0
    exit 1
fi

#  Populate up Root FS and install Boot Environment.
#
echo "$0: QCOW Filesystem Mounted, Installing System..."

pushd ${QCOW_ROOTFS_PATH}
if [ $? -ne 0 ]
then
    echo "$0: Unable to pushd into QCOW_ROOTFS_PATH [$QCOW_ROOTFS_PATH], FAIL"
    echo "$0:   Check for mounted and dangling /dev/nbd0,"
    echo "$0:   doing forced cleanup before exit."
    
    sudo umount ${QCOW_ROOTFS_PATH}
    sleep 1
    sudo qemu-nbd -d /dev/nbd0

    exit 1
fi

#  Install Root FS base.
#
sudo cp -Rp ${ROOTFS_PATH}/* .
popd

echo "$0: Mounting for Package Install"
do_qcow_mount
if [ $? -ne 0 ]
then
    echo "$0: do_qcow_mount FAILED"
    sudo umount ${QCOW_ROOTFS_PATH}
    sleep 1
    sudo qemu-nbd -d /dev/nbd0
    exit 1
fi

echo "$0: Doing Package Install"
sudo chroot ${QCOW_ROOTFS_PATH} sh -c "\
	export DEBIAN_FRONTEND=noninteractive;\
	export LC_ALL=C.UTF-8;\
	apt-get update; \
	apt-get install -y grub-pc;"

echo "$0: Unmounting after Package Install"
do_qcow_unmount
if [ $? -ne 0 ]
then
    echo "$0: do_unmount FAILED"
    sleep 1
    sudo qemu-nbd -d /dev/nbd0
    exit 1
fi

sudo grub-install /dev/nbd0 --root-directory=${QCOW_ROOTFS_PATH} --modules="biosdisk part_msdos"

#  Install final overlay to tune the boot.
#
echo "$0: Installing Overlay"
pushd ${QCOW_ROOTFS_PATH}
sudo cp -R ${ROOTFS_OVERLAY_DIR}/* .
popd

#  Set Root Password
#
sudo chroot ${QCOW_ROOTFS_PATH} sh -c "\
	echo root:infinera | chpasswd;"

# Enable Root Login via ssh.
#
cp ${QCOW_ROOTFS_PATH}/etc/ssh/sshd_config .
sudo cat sshd_config | sed 's/#PermitRootLogin.*/PermitRootLogin yes/' > sshd_config.nopasswd
sudo cp sshd_config.nopasswd ${QCOW_ROOTFS_PATH}/etc/ssh/sshd_config
sudo chown root:root ${QCOW_ROOTFS_PATH}/etc/ssh/sshd_config 
sudo chmod 644 ${QCOW_ROOTFS_PATH}/etc/ssh/sshd_config 
sudo rm -f sshd_config
rm -f sshd_config.nopasswd


echo "$0: System Installed.."

#  Cleanup and exit.
#
sudo umount ${QCOW_ROOTFS_PATH}
if [ $? -ne 0 ]
then
    echo "$0: unmount of ./qcow_mnt Failed, maybe dangling /dev/nbd0"
    sleep 1
    sudo qemu-nbd -d /dev/nbd0
    exit 1
fi

sudo qemu-nbd -d /dev/nbd0
if [ $? -ne 0 ]
then
    echo "$0: qemu-nbd -d /dev/nbd0 failed"
    exit 1
fi

exit 0
