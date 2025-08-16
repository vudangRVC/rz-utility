#!/bin/bash
source ./common.sh

getcode_atf()
{
    BOARD=$1
    cd ${WORKPWD}/

    # download atf
    if [ ! -d ${ATF_DIR} ]; then
        git clone $ATF_GIT_URL ${ATF_DIR} --jobs 16
    fi

    cd ${WORKPWD}/${ATF_DIR}
    if [ "${BOARD}" == "v2l-evk" ] ; then
        git checkout ${ATF_BRANCH_V2L_EVK}
    elif [ "${BOARD}" == "g2l-sbc" ] ; then
        git checkout ${ATF_BRANCH_G2L_SBC}
    elif [ "${BOARD}" == "g2l-evk" ] ; then
        git checkout ${ATF_BRANCH_G2L_EVK}
    elif [ "${BOARD}" == "g2l-100" ] ; then
        git checkout ${ATF_BRANCH_G2L_100}
    elif [ "${BOARD}" == "v2h-evk" ] ; then
        git checkout ${ATF_BRANCH_V2H_EVK}
    else
        echo "Error: Unsupported BOARD type: ${BOARD}"
        exit 1
    fi
}

mk_atf()
{
    BOARD=$1
    cd ${WORKPWD}/${ATF_DIR}/
    unset CFLAGS CPPFLAGS CXXFLAGS LDFLAGS
    make clean
    make distclean

    if [ "${BOARD}" == "v2l-evk" ] ; then
        echo "build atf for v2l-evk"
        make -j12 PLAT=v2l BOARD=smarc_rzv2l bl2_with_dtb bl31
    elif [ "${BOARD}" == "g2l-sbc" ] ; then
        echo "build atf for g2l-sbc"
        make -j12 PLAT=g2l BOARD=sbc_1 bl2_with_dtb bl31
    elif [ "${BOARD}" == "g2l-evk" ] ; then
        echo "build atf for g2l-evk"
        make -j12 PLAT=g2l BOARD=smarc_pmic_2 bl2_with_dtb bl31
    elif [ "${BOARD}" == "g2l-100" ] ; then
        echo "build atf for g2l-100"
        make -j12 PLAT=g2l BOARD=rzg2l_100 bl2_with_dtb bl31
    elif [ "${BOARD}" == "v2h-evk" ] ; then
        echo "build atf for v2h-evk"
        make -j12 PLAT=v2h BOARD=v2h_evk_1 ENABLE_STACK_PROTECTOR=default bl2_with_dtb bl31
    else
        echo "Error: Unsupported BOARD type: ${BOARD}"
        exit 1
    fi

    [ $? -ne 0 ] && log_error "Failed in ${ATF_DIR} ..." && exit
}

function main_process(){
    BOARD=$1
    validate_board "${BOARD}"
    set_toolchain
    getcode_atf $BOARD
    mk_atf $BOARD
}

#--start--------
# ./build_atf.sh v2h-evk
# ./build_atf.sh v2l-evk
# ./build_atf.sh g2l-sbc
# ./build_atf.sh g2l-evk
# ./build_atf.sh g2l-100
main_process $*

exit
#---- end ------