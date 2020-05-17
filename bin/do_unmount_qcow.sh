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


pushd ${IMAGES_DIR}
if [ $? -ne 0 ]
then
    echo "$0: Can't pushd into IMAGE_DIR [$IMAGES_DIR], Fail"
    exit 1
fi

#  Unmount
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

echo "$0: <debian.qcow2> Unmounted.."

popd

exit 0
