#!/bin/bash
source ./common.sh

ATF_GIT_URL="git@github.com:vudangRVC/rz-atf-sst.git"
ATF_BRANCH_RZPI="support_fconf-rzpi"

ATF_BRANCH_V2L="support_fconf-v2l"

ATF_BRANCH_G2L="atf-pass-params-g2l"

ATF_BRANCH_G2L100="atf-pass-params-g2l"

getcode_atf()
{
    BOARD=$1
    cd ${WORKPWD}/

    # download atf
    if [ ! -d ${ATF_DIR} ]; then
        git clone $ATF_GIT_URL ${ATF_DIR} --jobs 16
    fi

    cd ${WORKPWD}/${ATF_DIR}
    if [ "${BOARD}" == "v2l" ] ; then
        git checkout ${ATF_BRANCH_V2L}
    elif [ "${BOARD}" == "rzpi" ] ; then
        git checkout ${ATF_BRANCH_RZPI}
    elif [ "${BOARD}" == "g2l" ] ; then
        git checkout ${ATF_BRANCH_G2L}
    elif [ "${BOARD}" == "g2l100" ] ; then
        git checkout ${ATF_BRANCH_G2L100}
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

    if [ "${BOARD}" == "v2l" ] ; then
        echo "build atf for rzv2l"
        make PLAT=v2l BOARD=smarc_rzv2l bl2_with_dtb bl31
    elif [ "${BOARD}" == "rzpi" ] ; then
        echo "build atf for rzpi"
        make -j12 PLAT=g2l BOARD=sbc_1 bl2_with_dtb bl31
    elif [ "${BOARD}" == "g2l" ] ; then
        echo "build atf for g2l"
        make PLAT=g2l BOARD=smarc_pmic_2 bl2 bl31
    elif [ "${BOARD}" == "g2l100" ] ; then
        echo "build atf for g2l100"
        make PLAT=g2l BOARD=smarc_pmic_2 bl2 bl31
    else
        echo "Error: Unsupported BOARD type: ${BOARD}"
        exit 1
    fi

    [ $? -ne 0 ] && log_error "Failed in ${ATF_DIR} ..." && exit
}

function main_process(){
    BOARD=$1
    validate_board "${BOARD}"
    getcode_atf $BOARD
    mk_atf $BOARD
}

#--start--------
# ./build_atf.sh v2h
# ./build_atf.sh v2l
# ./build_atf.sh rzpi
# ./build_atf.sh g2l
# ./build_atf.sh g2l100
main_process $*

exit
#---- end ------