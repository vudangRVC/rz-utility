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

# ATF_GIT_URL="git@github.com:vudangRVC/rz-atf-sst.git"
# ATF_BRANCH_RZPI="load-multi-dtb"
# ATF_COMMIT_RZPI=""

# ATF_BRANCH_V2L="rzv2l-multi-dtb"
# ATF_COMMIT_V2L="6142c6afd8b6e4bdaa9d34ad7f9b099eeb8d05b6"

ATF_GIT_URL="git@github.com:vudangRVC/rz-atf-sst.git"
ATF_BRANCH_V2H="dev-rzv2h"
# ATF_COMMIT_V2H="2b0c18857eebc7a973f611500f6615e991e2625e"

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
    elif [ "${SOC_TYPE}" == "v2h" ] ; then
        git checkout ${ATF_BRANCH_V2H}
        git checkout ${ATF_COMMIT_V2H}
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
        make -j12 PLAT=v2l BOARD=smarc_pmic_2 bl2 bl31
    elif [ "${SOC_TYPE}" == "rzpi" ] ; then
        echo "build atf for rzpi"
        make -j12 PLAT=g2l BOARD=sbc_1 all
    elif [ "${SOC_TYPE}" == "v2h" ] ; then
        echo "build atf for rzv2h"
        make -j12 PLAT=v2h BOARD=evk_1 ENABLE_STACK_PROTECTOR=default bl2 bl31
        # make -j12 PLAT=v2h BOARD=evk_1 all
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
# ./build_atf.sh v2h
main_process $*

exit
#---- end ------