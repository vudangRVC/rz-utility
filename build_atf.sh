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

ATF_GIT_URL="git@github.com:vudangRVC/rz-atf-sst.git"
ATF_BRANCH_RZPI="load-multi-dtb"
ATF_COMMIT_RZPI="2f872ba09fd8dec74aabcddfa806cedcba280e19"

ATF_BRANCH_V2L="load-multi-dtb"
ATF_COMMIT_V2L="2f872ba09fd8dec74aabcddfa806cedcba280e19"

# ATF_BRANCH_V2L="load-multi-dtb"
# ATF_COMMIT_V2L="848411f689a0f60ec9957f8b794e39f0f47cc812"
# ATF_COMMIT_V2L="c314a391cf3eaf904e3b7a2875af15cc8254dab5"

# ATF_GIT_URL="https://github.com/renesas-rz/rzg_trusted-firmware-a"
# ATF_BRANCH_V2L="v2.6/rz"
# ATF_COMMIT_V2L="aed3786384b99dc13a46a8d3af139df28b5642a3"


getcode_atf()
{   SOC_TYPE=$1
    cd ${WORKPWD}/

    # download atf
    if [ ! -d {ATF_DIR} ];then
        git clone $ATF_GIT_URL ${ATF_DIR} --jobs 16
    fi

    cd ${WORKPWD}/${ATF_DIR}
    if [ "${SOC_TYPE}" == "v2l" ] ; then
        git checkout ${ATF_BRANCH_V2L}
        git checkout ${ATF_COMMIT_V2L}
    else
        git checkout ${ATF_BRANCH_RZPI}
        git checkout ${ATF_COMMIT_RZPI}
    fi
}

mk_atf()
{
    SOC_TYPE=$1
    cd ${WORKPWD}/${ATF_DIR}/
    unset CFLAGS CPPFLAGS CXXFLAGS LDFLAGS
    make clean
    make distclean
    if [ "${SOC_TYPE}" == "v2l" ] ; then
        echo "build atf for rzv2l"
        make PLAT=v2l BOARD=smarc_pmic_2 bl2 bl31
    elif [ "${SOC_TYPE}" == "rzpi" ] ; then
        echo "build atf for rzpi"
        make -j12 PLAT=g2l BOARD=sbc_1 all
    else
        echo "build atf for rzsbc"
        make PLAT=v2l BOARD=rzboard bl2 bl31
    fi
    [ $? -ne 0 ] && log_error "Failed in ${ATF_DIR} ..." && exit
}

function main_process(){
    SOC_TYPE=$1
    getcode_atf $SOC_TYPE
    mk_atf $SOC_TYPE
}

#--start--------
# ./build_atf.sh v2l
# ./build_atf.sh rzpi
main_process $*

exit
#---- end ------