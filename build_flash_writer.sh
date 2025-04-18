#!/bin/bash

source ./common.sh

FWT_GIT_URL="git@github.com:vudangRVC/flash-writer-sst.git"
FWT_BRANCH="dunfell/rz-sbc"
FWT_COMMIT_V2L="ff167b676547f3997906c82c9be504eb5cff8ef0"
FWT_COMMIT_G2L="ff167b676547f3997906c82c9be504eb5cff8ef0"
FWT_COMMIT_RZPI="8e5919a314673217d93dbb34227b8c22d71d681b"

getcode_flash-writer()
{
    SOC_TYPE=$1
    cd ${WORKPWD}/
    # download flash-writer
    if [ ! -d {FWT_DIR} ];then
        git clone $FWT_GIT_URL ${FWT_DIR} --jobs 16
    fi

    cd ${WORKPWD}/${FWT_DIR}
    if [ "${SOC_TYPE}" == "v2l" ] ; then
        git checkout ${FWT_COMMIT_V2L}
    elif [ "${SOC_TYPE}" == "rzpi" ] ; then
        git checkout ${FWT_COMMIT_RZPI}
    elif [ "${SOC_TYPE}" == "g2l" ] ; then
        git checkout ${FWT_COMMIT_G2L}
    else
        echo "Please input the right soc type"
        exit
    fi
}

mk_flash-writer()
{
    SOC_TYPE=$1
    cd ${WORKPWD}
    rm *.mot
    cd ${WORKPWD}/${FWT_DIR}/
    make clean
    if [ "${SOC_TYPE}" == "v2l" ] ; then
        git checkout ${FWT_COMMIT_V2L}
        make BOARD=RZV2L_SMARC_PMIC    -j12
        cp AArch64_output/Flash_Writer_SCIF_RZV2L_SMARC_PMIC_DDR4_2GB_1PCS.mot ${WORKPWD}
    elif [ "${SOC_TYPE}" == "rzpi" ] ; then
        git checkout ${FWT_COMMIT_RZPI}
        make BOARD=RZG2L_SBC    -j12
        cp AArch64_output/Flash_Writer_SCIF_RZG2L_SBC_DDR4_1GB.mot ${WORKPWD}/Flash_Writer_SCIF_rzpi.mot
    elif [ "${SOC_TYPE}" == "g2l" ] ; then
        git checkout ${FWT_COMMIT_G2L}
        make BOARD=RZG2L_SMARC_PMIC    -j12
        cp AArch64_output/Flash_Writer_SCIF_RZG2L_SMARC_PMIC_DDR4_2GB_1PCS.mot ${WORKPWD}
    else
        echo "Error: Invalid SOC_TYPE."
        exit 1
    fi
    [ $? -ne 0 ] && log_error "Failed in ${FWT_DIR} ..." && exit
}

function main_process(){
    SOC_TYPE=$1
    validate_soc_type "${SOC_TYPE}"
    getcode_flash-writer $SOC_TYPE
    mk_flash-writer  $SOC_TYPE
}

# call function
# ./build_flash_writer.sh v2h
# ./build_flash_writer.sh v2l
# ./build_flash_writer.sh rzpi
# ./build_flash_writer.sh g2l
main_process $1

