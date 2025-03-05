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
ATF_DIR="trusted-firmware-a"

# ATF_GIT_URL="git@github.com:sonnguyenxg/rz-atf.git"
# ATF_DIR="trusted-firmware-a"
# ATF_BRANCH="dunfell/rz-sbc"

ATF_GIT_URL="https://github.com/renesas-rz/rzg_trusted-firmware-a"
ATF_BRANCH="v2.6/rz"
ATF_COMMIT="aed3786384b99dc13a46a8d3af139df28b5642a3"

getcode_atf()
{
    cd ${WORKPWD}/
    # download atf
    if [ ! -d {ATF_DIR} ];then
        git clone $ATF_GIT_URL ${ATF_DIR} --jobs 16
        git -C ${ATF_DIR} checkout ${ATF_BRANCH}
        git -C ${ATF_DIR} checkout ${ATF_COMMIT}
    fi
}

mk_atf()
{
    SOC_TYPE=$1
    cd ${WORKPWD}/${ATF_DIR}/
    unset CFLAGS CPPFLAGS CXXFLAGS LDFLAGS
    if [ "${SOC_TYPE}" == "v2l" ] ; then
        echo "build atf for rzv2l";
        unset CFLAGS CPPFLAGS CXXFLAGS LDFLAGS
        make clean
        make distclean
        make PLAT=v2l BOARD=smarc_pmic_2 bl2 bl31
    else
        echo "build atf for avnet"
        make clean
        make distclean
        unset CFLAGS CPPFLAGS CXXFLAGS LDFLAGS
        make PLAT=v2l BOARD=rzboard bl2 bl31
    fi
    [ $? -ne 0 ] && log_error "Failed in ${ATF_DIR} ..." && exit
}

# call function
getcode_atf
mk_atf v2l

