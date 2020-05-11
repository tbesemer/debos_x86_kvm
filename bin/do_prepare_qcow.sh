#!/bin/sh

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

mkdir -p qcow_mnt
sudo mount /dev/nbd0p2 ./qcow_mnt
if [ $? -ne 0 ]
then
    echo "$0: mkfs.ext4 on /dev/ndb0p2 Failed"
    sudo qemu-nbd -d /dev/nbd0
    exit 1
fi

#  Populate up Root FS and install Boot Environment.
#
echo "$0: QCOW Filesystem Mounted, Installing System..."
sleep 5
echo "$0: System Installed.."

#  Cleanup and exit.
#
sudo umount ./qcow_mnt
if [ $? -ne 0 ]
then
    echo "$0: unmount of ./qcow_mnt Failed, dangling /dev/nbd0"
    exit 1
fi

sudo qemu-nbd -d /dev/nbd0
if [ $? -ne 0 ]
then
    echo "$0: qemu-nbd -d /dev/nbd0 failed"
    exit 1
fi

exit 0
