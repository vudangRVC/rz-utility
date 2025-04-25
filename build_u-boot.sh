#!/bin/bash

source ./common.sh

UBOOT_GIT_URL="git@github.com:vudangRVC/u-boot-sst.git"
UBOOT_BRANCH="rz-support-multi-boards"

getcode_u-boot()
{
    cd ${WORKPWD}/
    # download u-boot
    if [ ! -d {UBOOT_DIR} ];then
        git clone $UBOOT_GIT_URL ${UBOOT_DIR} --jobs 16
    fi
    cd ${WORKPWD}/${UBOOT_DIR}
    git checkout ${UBOOT_BRANCH}
}

mk_u-boot()
{
    SOC_TYPE=$1
    cd ${WORKPWD}/${UBOOT_DIR}/
    unset CFLAGS CPPFLAGS CXXFLAGS LDFLAGS
    make clean
    make distclean
    make rz-multi-board_defconfig
    make -j12
    [ $? -ne 0 ] && log_error "Failed in ${UBOOT_DIR} ..." && exit
}

function main_process(){
    SOC_TYPE=$1
    validate_soc_type "${SOC_TYPE}"
    getcode_u-boot
    mk_u-boot $SOC_TYPE
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
