#!/bin/bash

ARM_GCC_VERSION="SDK"
if [ "${ARM_GCC_VERSION}" == "SDK" ] ; then
source /opt/poky/3.1.14/environment-setup-aarch64-poky-linux
else
## gcc 10.3 default
TOOLCHAIN_PATH=$HOME/toolchain/gcc-arm-10.3-2021.07-x86_64-aarch64-none-linux-gnu/bin
export PATH=$TOOLCHAIN_PATH:$PATH
export ARCH=arm64
export CROSS_COMPILE=aarch64-none-linux-gnu-
fi

WORKPWD=$(pwd)
UBOOT_DIR="uboot"

UBOOT_GIT_URL="git@github.com:vudangRVC/u-boot-sst.git"
UBOOT_BRANCH="rzv2h-multi-dtb"
# UBOOT_COMMIT="cabe8c49d240ebe8ec76b33b0851c0c700bb2b70"

getcode_u-boot()
{
    cd ${WORKPWD}/
    # download u-boot
    if [ ! -d {UBOOT_DIR} ];then
        git clone $UBOOT_GIT_URL ${UBOOT_DIR} --jobs 16
        git -C ${UBOOT_DIR} checkout ${UBOOT_BRANCH}
        # git -C ${UBOOT_DIR} checkout ${UBOOT_COMMIT}
    fi
}

mk_u-boot()
{
    SOC_TYPE=$1
    cd ${WORKPWD}/${UBOOT_DIR}/
    unset CFLAGS CPPFLAGS CXXFLAGS LDFLAGS
    make clean
    make distclean
    if [ "${SOC_TYPE}" == "v2l" ] ; then
        make smarc-rzv2l_defconfig
    elif [ "${SOC_TYPE}" == "rzpi" ] ; then
        make rzpi_defconfig
    elif [ "${SOC_TYPE}" == "v2h" ] ; then
        make rzv2h-evk-ver1_defconfig
    else
        make defconfig
    fi
    make -j12
    [ $? -ne 0 ] && log_error "Failed in ${UBOOT_DIR} ..." && exit
}

function main_process(){
    SOC_TYPE=$1
    getcode_u-boot
    mk_u-boot $SOC_TYPE
}

#--start--------
# ./build_atf.sh v2l
# ./build_atf.sh rzpi
# ./build_atf.sh v2h
main_process $*

exit
#---- end ------
