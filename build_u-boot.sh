#!/bin/bash

source ./common.sh

getcode_u-boot()
{
    cd ${WORKPWD}/
    # download u-boot
    if [ ! -d ${UBOOT_DIR} ]; then
        git clone $UBOOT_GIT_URL ${UBOOT_DIR} --jobs 16
    fi

    cd ${WORKPWD}/${UBOOT_DIR}
    if [ "${BOARD}" == "v2l-evk" ] ; then
        git checkout ${UBOOT_BRANCH_V2L_EVK}
    elif [ "${BOARD}" == "g2l-sbc" ] ; then
        git checkout ${UBOOT_BRANCH_G2L_SBC}
    elif [ "${BOARD}" == "g2l-evk" ] ; then
        git checkout ${UBOOT_BRANCH_G2L_EVK}
    elif [ "${BOARD}" == "g2l-100" ] ; then
        git checkout ${UBOOT_BRANCH_G2L_100}
    elif [ "${BOARD}" == "v2h-evk" ] ; then
        git checkout ${UBOOT_BRANCH_V2H_EVK}
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
    if [ "${BOARD}" == "v2h-evk" ] ; then
        make -j12 rzv2h-evk-ver1_defconfig
    elif [ "${BOARD}" == "g2l-sbc" ] ; then
        make -j12 rz-cmn_defconfig
    elif [ "${BOARD}" == "v2l-evk" ] ; then
        make -j12 rz-cmn_defconfig
    elif [ "${BOARD}" == "g2l-evk" ] ; then
        make -j12 rz-cmn_defconfig
    elif [ "${BOARD}" == "g2l-100" ] ; then
        make -j12 rz-cmn_defconfig
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
# ./build_u-boot.sh v2h-evk
# ./build_u-boot.sh v2l-evk
# ./build_u-boot.sh g2l-sbc
# ./build_u-boot.sh g2l-evk
# ./build_u-boot.sh g2l-100
main_process $*

exit
#---- end ------
