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

if [ $EUID -ne 0 ]
then
    echo "$0: EUID == $EUID, please run as EUID 0"
    exit 1
fi

if [ ! -d ${ROOTFS_PATH} ]
then
    echo "$0: ROOTFS_PATH missing [${ROOTFS_PATH}], no action being taken"
    exit 0
fi

#  Past safety checks prior to doing 'rm' action as
#  root....
#
#  Too many destroyed servers in the past to not
#  do these safety checks.
#
#  Simply delete things out, but we pushd into the
#  images directory as one final safety check.
#
pushd ${IMAGES_DIR}
if [ $? -ne 0 ]
then
    echo "$0: pushd failed on IMAGES_DIR [${IMAGES_DIR}]"
    exit 1
fi

rm -rf ${ROOTFS_NAME}
rm -f "${ROOTFS_NAME}".tgz

popd

exit 0
