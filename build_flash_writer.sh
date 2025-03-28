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

FWT_GIT_URL="git@github.com:vudangRVC/flash-writer-sst.git"
FWT_BRANCH="dunfell/rz-sbc"
FWT_DIR="flash_writer"
FWT_COMMIT_V2L="ff167b676547f3997906c82c9be504eb5cff8ef0"
FWT_COMMIT_RZPI="8e5919a314673217d93dbb34227b8c22d71d681b"

getcode_flash-writer()
{
    SOC_TYPE=$1
    cd ${WORKPWD}/
    # download flash-writer
    if [ ! -d {FWT_DIR} ];then
        git clone $FWT_GIT_URL ${FWT_DIR} --jobs 16
        git -C ${FWT_DIR} checkout ${FWT_BRANCH}
    fi

    cd ${WORKPWD}/${FWT_DIR}
    if [ "${SOC_TYPE}" == "v2l" ] ; then
        git checkout ${FWT_COMMIT_V2L}
    else
        git checkout ${FWT_COMMIT_RZPI}
    fi
}

mk_flash-writer()
{
    SOC_TYPE=$1
    cd ${WORKPWD}
    rm *.mot
    cd ${WORKPWD}/${FWT_DIR}/
    if [ "${SOC_TYPE}" == "v2l" ] ; then
        git checkout ${FWT_COMMIT_V2L}
        make clean
        make BOARD=RZV2L_SMARC_PMIC    -j12
        cp AArch64_output/Flash_Writer_SCIF_RZV2L_SMARC_PMIC_DDR4_2GB_1PCS.mot ${WORKPWD}
    else
        make clean
        make BOARD=RZG2L_SMARC_PMIC    -j12
    fi
    [ $? -ne 0 ] && log_error "Failed in ${FWT_DIR} ..." && exit
}

function main_process(){
    SOC_TYPE=$1
    getcode_flash-writer $SOC_TYPE
    mk_flash-writer  $SOC_TYPE
}

# call function
# ./build_flash_writer.sh v2l
# ./build_flash_writer.sh rzpi
main_process $1

