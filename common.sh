#!/bin/bash
WORKPWD=$(pwd)

# flash writer variables
FWT_DIR="flash_writer"
FWT_GIT_URL="git@github.com:Renesas-SST/flash-writer.git"
FWT_BRANCH_MULTIBOARD="styhead/rz-cmn"

# ATF variables
ATF_DIR="trusted-firmware-a"
ATF_GIT_URL="git@github.com:vudangRVC/rz-atf-sst.git"
ATF_BRANCH_G2L_SBC="styhead/rz-cmn-fconf"
ATF_BRANCH_V2L_EVK="styhead/rz-cmn-fconf"
ATF_BRANCH_G2L_EVK="styhead/rz-cmn-fconf"
ATF_BRANCH_G2L_100="styhead/rz-cmn-fconf"
ATF_BRANCH_V2H_EVK="styhead/rz-cmn-fconf"

# u-boot variables
UBOOT_DIR="uboot"
UBOOT_GIT_URL="git@github.com:Renesas-SST/u-boot.git"
UBOOT_BRANCH_G2L_SBC="styhead/rz-cmn"
UBOOT_BRANCH_V2L_EVK="styhead/rz-cmn"
UBOOT_BRANCH_G2L_EVK="styhead/rz-cmn"
UBOOT_BRANCH_G2L_100="styhead/rz-cmn"
UBOOT_BRANCH_V2H_EVK="v2021.10/rzv2h"

# boot parameter variables
BOOTPARAMETER_DIR="bootparameter_dir"

set_toolchain() {
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
}

validate_board() {
    BOARD=$1
    case "${BOARD}" in
        v2h-evk|v2l-evk|g2l-sbc|g2l-evk|g2l-100)
            return 0
            ;;
        *)
            echo "BOARD is not supported"
            echo "Please use one of: v2h-evk, v2l-evk, g2l-evk, g2l-sbc, g2l-100"
            echo "Example: ./all_build.sh v2h-evk"
            echo "Example: ./all_build.sh v2l-evk"
            echo "Example: ./all_build.sh g2l-evk"
            echo "Example: ./all_build.sh g2l-sbc"
            echo "Example: ./all_build.sh g2l-100"
            exit 1
            ;;
    esac
}
