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
FWT_DIR="flash_writer"
ATF_DIR="trusted-firmware-a"
UBOOT_DIR="uboot"
BOOTPARAMETER_DIR="bootparameter_dir"

validate_soc_type() {
    SOC_TYPE=$1
    case "${SOC_TYPE}" in
        v2h|v2l|rzpi|g2l|g2l100)
            return 0
            ;;
        *)
            echo "SOC_TYPE is not supported"
            echo "Please use rzpi or v2l or g2l or v2h"
            echo "example: ./all_build.sh v2h"
            echo "example: ./all_build.sh rzpi"
            echo "example: ./all_build.sh v2l"
            echo "example: ./all_build.sh g2l"
            echo "example: ./all_build.sh g2l100"
            exit 1
            ;;
    esac
}
