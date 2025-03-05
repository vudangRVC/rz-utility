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
UBOOT_DIR="u-boot"

UBOOT_GIT_URL="git@github.com:vudangRVC/u-boot-sst.git"
UBOOT_BRANCH="dunfell/rz-sbc"
UBOOT_COMMIT="d9dfaef946f9299983302fa2ad10543db35aaade"

# UBOOT_GIT_URL="https://github.com/renesas-rz/renesas-u-boot-cip.git"
# UBOOT_BRANCH="v2020.10/rzg2l"
# UBOOT_COMMIT="0767c36bea79f82c27e4efd3f3d11670c81741b0"

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
        # make smarc-rzv2l_defconfig
        make common_defconfig
    else
        make rzboard_defconfig
    fi
    make -j12
    [ $? -ne 0 ] && log_error "Failed in ${UBOOT_DIR} ..." && exit
}

# call function
# getcode_u-boot
mk_u-boot v2l

