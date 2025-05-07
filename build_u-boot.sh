#!/bin/bash

source ./common.sh

UBOOT_GIT_URL="git@github.com:vudangRVC/u-boot-sst.git"
UBOOT_BRANCH="rz-support-multi-boards"
UBOOT_BRANCH_V2H="v2021.10/rzv2h"

getcode_u-boot()
{
    BOARD=$1
    cd ${WORKPWD}/
    # download u-boot
    if [ ! -d ${UBOOT_DIR} ]; then
        git clone $UBOOT_GIT_URL ${UBOOT_DIR} --jobs 16
    fi
    cd ${WORKPWD}/${UBOOT_DIR}
    if [ "${BOARD}" == "v2h" ] ; then
        git checkout ${UBOOT_BRANCH_V2H}
    else
        git checkout ${UBOOT_BRANCH}
    fi
}

mk_u-boot()
{
    BOARD=$1
    cd ${WORKPWD}/${UBOOT_DIR}/
    unset CFLAGS CPPFLAGS CXXFLAGS LDFLAGS
    make clean
    make distclean
    if [ "${BOARD}" == "v2h" ] ; then
        make -j12 rzv2h-evk-ver1_defconfig
    else
        make rz-multi-boards_defconfig
    fi
    make -j12
    [ $? -ne 0 ] && log_error "Failed in ${UBOOT_DIR} ..." && exit
}

function main_process(){
    BOARD=$1
    validate_board "${BOARD}"
    getcode_u-boot $BOARD
    mk_u-boot $BOARD
}

#--start--------
# ./build_u-boot.sh v2h
# ./build_u-boot.sh v2l
# ./build_u-boot.sh rzpi
# ./build_u-boot.sh g2l
# ./build_u-boot.sh g2l100
main_process $*

exit
#---- end ------
