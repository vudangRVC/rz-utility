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
UBOOT_BRANCH="rzv2l-fit"
UBOOT_COMMIT="7b87e36f6fe67c37794ffa9405824ee97db17cc6"

getcode_u-boot()
{
    cd ${WORKPWD}/
    # download u-boot
    if [ ! -d {UBOOT_DIR} ];then
        git clone $UBOOT_GIT_URL ${UBOOT_DIR} --jobs 16
        git -C ${UBOOT_DIR} checkout ${UBOOT_BRANCH}
        git -C ${UBOOT_DIR} checkout ${UBOOT_COMMIT}
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
        make smarc-rzv2l_defconfig
    else
        make common_defconfig
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
# ./build_u-boot.sh rzpi
# ./build_u-boot.sh v2l
main_process $*

exit
#---- end ------
