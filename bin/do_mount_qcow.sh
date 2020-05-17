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

if [ ! -f ${ROOT_DIR}/images/debian.qcow2 ] 
then
   echo "$0: ERROR: ROOT_DIR/images/debian.qcow2 missing, FAIL"
   exit 1
fi

QCOW_ROOTFS_PATH=${IMAGES_DIR}/${QCOW_ROOTFS_NAME}

echo "$0: Installing nbd module"
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

echo "$0: Attaching debian.qcow2 to nbd"
sudo qemu-nbd -c /dev/nbd0 debian.qcow2
if [ $? -ne 0 ]
then
    echo "$0: qemu-ndb on /dev/ndb0 Failed"
    exit 1
fi

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

echo "$0: <debian.qcow2> Mounted.."

popd

exit 0
