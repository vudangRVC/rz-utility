#!/bin/bash
source ./common.sh

ATF_GIT_URL="git@github.com:vudangRVC/rz-atf-sst.git"
ATF_BRANCH_RZPI="atf-pass-params"
ATF_COMMIT_RZPI="032b45511cb339615c8450e9ab43338f57949fe3"

ATF_BRANCH_V2L="atf-pass-params-v2l"
ATF_COMMIT_V2L="2f839d57673d02b400e64579e59221c14cae260c"

ATF_BRANCH_G2L="atf-pass-params-g2l"
ATF_COMMIT_G2L="dd04e587c6a7db554953eaf0bf249335b169a116"

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
    elif [ "${SOC_TYPE}" == "rzpi" ] ; then
        git checkout ${ATF_BRANCH_RZPI}
    else
        git checkout ${ATF_BRANCH_G2L}
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
    elif [ "${SOC_TYPE}" == "g2l" ] ; then
        echo "build atf for g2l"
        make PLAT=g2l BOARD=smarc_pmic_2 bl2 bl31
    else
        echo "Please input the right soc type"
        exit
    fi
    [ $? -ne 0 ] && log_error "Failed in ${ATF_DIR} ..." && exit
}

function main_process(){
    SOC_TYPE=$1
    validate_soc_type "${SOC_TYPE}"
    getcode_atf $SOC_TYPE
    mk_atf $SOC_TYPE
}

#--start--------
# ./build_atf.sh v2h
# ./build_atf.sh v2l
# ./build_atf.sh rzpi
# ./build_atf.sh g2l
main_process $*

exit
#---- end ------