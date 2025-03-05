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
FWT_GIT_URL="https://github.com/renesas-rz/rzg2_flash_writer"
FWT_BRANCH="rz_g2l"
FWT_DIR="flash_writer"

getcode_flash-writer()
{
    cd ${WORKPWD}/
    # download flash-writer
    if [ ! -d {FWT_DIR} ];then
        git clone $FWT_GIT_URL ${FWT_DIR} --jobs 16
        git -C ${FWT_DIR} checkout ${FWT_BRANCH}
    fi
}

mk_flash-writer()
{
    SOC_TYPE=$1
    cd ${WORKPWD}/${FWT_DIR}/
    if [ "${SOC_TYPE}" == "v2l" ] ; then
        make clean
        make BOARD=RZV2L_SMARC_PMIC    -j12
        cp AArch64_output/Flash_Writer_SCIF_RZV2L_SMARC_PMIC_DDR4_2GB_1PCS.mot ${WORKPWD}
    else
        make clean
        make BOARD=RZG2L_SMARC_PMIC    -j12
    fi
    [ $? -ne 0 ] && log_error "Failed in ${FWT_DIR} ..." && exit
}

# call function
getcode_flash-writer
mk_flash-writer v2l

