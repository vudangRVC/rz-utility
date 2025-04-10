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

UBOOT_GIT_URL_V2L="git@github.com:vudangRVC/u-boot-sst.git"
UBOOT_BRANCH_V2L="rzv2l-fit"
# UBOOT_COMMIT_V2L="36bfaf82279ecd87ed918550b5de505091768bb7"

UBOOT_GIT_URL_RZPI="git@github.com:vudangRVC/u-boot-sst.git"
UBOOT_BRANCH_RZPI="rzv2l"
# UBOOT_COMMIT_RZPI="fbb5ab9591a1ff6893417e7cf3ead56e5d8a3c8c"

getcode_u-boot()
{
    SOC_TYPE=$1
    cd ${WORKPWD}/
    # download u-boot
    if [ ! -d {UBOOT_DIR} ];then
        git clone $UBOOT_GIT_URL ${UBOOT_DIR} --jobs 16
        # git -C ${UBOOT_DIR} checkout ${UBOOT_BRANCH}
        # git -C ${UBOOT_DIR} checkout ${UBOOT_COMMIT}
    fi
    
    cd ${WORKPWD}/${UBOOT_DIR}
    if [ "${SOC_TYPE}" == "v2l" ] ; then
        git checkout ${UBOOT_BRANCH_V2L}
        # git checkout ${UBOOT_COMMIT_V2L}
    else
        git checkout ${UBOOT_BRANCH_RZPI}
        # git checkout ${UBOOT_COMMIT_RZPI}
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
    getcode_u-boot $SOC_TYPE
    mk_u-boot $SOC_TYPE
}

#--start--------
# ./build_atf.sh v2l
# ./build_atf.sh rzpi
main_process $*

exit
#---- end ------
