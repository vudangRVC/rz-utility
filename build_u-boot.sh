#!/bin/bash

source ./common.sh

UBOOT_GIT_URL="git@github.com:vudangRVC/u-boot-sst.git"

UBOOT_BRANCH_RZPI="styhead/rz-sbc"
UBOOT_BRANCH_V2L="styhead/rz-sbc"
UBOOT_BRANCH_G2L="styhead/rz-sbc"
UBOOT_BRANCH_G2L100="atf-pass-params-g2l"
UBOOT_BRANCH_V2H="v2021.10/rzv2h"

getcode_u-boot()
{
    cd ${WORKPWD}/
    # download u-boot
    if [ ! -d ${UBOOT_DIR} ]; then
        git clone $UBOOT_GIT_URL ${UBOOT_DIR} --jobs 16
    fi

    cd ${WORKPWD}/${UBOOT_DIR}
    if [ "${BOARD}" == "v2l" ] ; then
        git checkout ${UBOOT_BRANCH_V2L}
    elif [ "${BOARD}" == "rzpi" ] ; then
        git checkout ${UBOOT_BRANCH_RZPI}
    elif [ "${BOARD}" == "g2l" ] ; then
        git checkout ${UBOOT_BRANCH_G2L}
    elif [ "${BOARD}" == "g2l100" ] ; then
        git checkout ${UBOOT_BRANCH_G2L100}
    elif [ "${BOARD}" == "v2h" ] ; then
        git checkout ${UBOOT_BRANCH_V2H}
    else
        echo "Error: Unsupported BOARD type: ${BOARD}"
        exit 1
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
    elif [ "${BOARD}" == "rzpi" ] ; then
        make -j12 rzpi_defconfig
    elif [ "${BOARD}" == "v2l" ] ; then
        make -j12 smarc-rzv2l_defconfig
    elif [ "${BOARD}" == "g2l" ] ; then
        make -j12 smarc-rzg2l_defconfig
    elif [ "${BOARD}" == "g2l100" ] ; then
        make -j12 rz-multi-boards_defconfig
    else
        echo "Error: Unsupported BOARD type: ${BOARD}"
        exit 1
    fi
    make -j12
    [ $? -ne 0 ] && log_error "Failed in ${UBOOT_DIR} ..." && exit
}

function main_process(){
    BOARD=$1
    validate_board "${BOARD}"
    set_toolchain
    getcode_u-boot
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
