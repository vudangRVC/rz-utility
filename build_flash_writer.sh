#!/bin/bash
source ./common.sh

getcode_flash-writer()
{
    cd ${WORKPWD}/
    # download flash-writer
    if [ ! -d {FWT_DIR} ];then
        git clone $FWT_GIT_URL ${FWT_DIR} --jobs 16
    fi

    cd ${WORKPWD}/${FWT_DIR}
    git checkout ${FWT_BRANCH_MULTIBOARD}
}

mk_flash-writer()
{
    BOARD=$1
    cd ${WORKPWD}
    rm *.mot
    cd ${WORKPWD}/${FWT_DIR}/
    make clean
    if [ "${BOARD}" == "v2l-evk" ] ; then
        make BOARD=RZV2L_SMARC_PMIC -j12
        cp AArch64_output/Flash_Writer_SCIF_RZV2L_SMARC_PMIC_DDR4_2GB_1PCS.mot ${WORKPWD}
    elif [ "${BOARD}" == "g2l-sbc" ] ; then
        make BOARD=RZG2L_SBC -j12
        cp AArch64_output/Flash_Writer_SCIF_RZG2L_SBC_DDR4_1GB.mot ${WORKPWD}/Flash_Writer_SCIF_rzg2l-sbc.mot
    elif [ "${BOARD}" == "g2l-evk" ] ; then
        make BOARD=RZG2L_SMARC_PMIC -j12
        cp AArch64_output/Flash_Writer_SCIF_RZG2L_SMARC_PMIC_DDR4_2GB_1PCS.mot ${WORKPWD}
    elif [ "${BOARD}" == "g2l-100" ] ; then
        make BOARD=RZG2L_15MMSQ_DEV -j12
        cp AArch64_output/Flash_Writer_SCIF_RZG2L_15MMSQ_DEV_DDR4_4GB.mot ${WORKPWD}
    else
        echo "Error: Invalid BOARD."
        exit 1
    fi
    [ $? -ne 0 ] && log_error "Failed in ${FWT_DIR} ..." && exit
}

function main_process(){
    BOARD=$1
    validate_board "${BOARD}"
    set_toolchain
    getcode_flash-writer $BOARD
    mk_flash-writer  $BOARD
}

# call function
# ./build_flash_writer.sh v2h-evk
# ./build_flash_writer.sh v2l-evk
# ./build_flash_writer.sh g2l-sbc
# ./build_flash_writer.sh g2l-evk
# ./build_flash_writer.sh g2l-100
main_process $1
