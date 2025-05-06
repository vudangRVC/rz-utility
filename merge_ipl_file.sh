#!/bin/bash
source ./common.sh

log_info(){
    local string=$1
    echo -ne "\e[32m $string \e[0m\n"
}

get_bootparameter()
{
    cd ${WORKPWD}/
    if [ ! -d ${BOOTPARAMETER_DIR} ]; then
        mkdir ${BOOTPARAMETER_DIR}
        cd ${BOOTPARAMETER_DIR}
        wget https://raw.githubusercontent.com/renesas-rz/meta-rzg2/dunfell/rzg2l/recipes-bsp/firmware-pack/bootparameter/bootparameter.c
    fi
    cd ${WORKPWD}/
}

check_extra_tools()
{
    cd ${WORKPWD}
    if [ ! -x fiptool ]; then
        make -C ${WORKPWD}/${ATF_DIR}/tools/fiptool/ fiptool
        cp -af ${WORKPWD}/${ATF_DIR}/tools/fiptool/fiptool ${WORKPWD}
        echo "copy fiptool "
    fi

    if [ ! -x bootparameter ]; then
        cd ${WORKPWD}/${BOOTPARAMETER_DIR}
        gcc bootparameter.c -o bootparameter
        cp bootparameter ${WORKPWD}
        cd ${WORKPWD}/
        echo "copy bootparameter "
    fi
}

mk_bootimage()
{
    BOARD=$1
    cd ${WORKPWD}
    BUILDMODE=release

    if [ "${BOARD}" == "v2h" ]; then
        SOC="v2h"
    elif [ "${BOARD}" == "v2l" ]; then
        SOC="v2l"
    elif [ "${BOARD}" == "rzpi" ] || [ "${BOARD}" == "g2l" ] || [ "${BOARD}" == "g2l100" ]; then
        SOC="g2l"
    else
        echo "Unsupported board: ${BOARD}"
        exit 1
    fi

    if [ ! -f ${WORKPWD}/${ATF_DIR}/build/${SOC}/${BUILDMODE}/bl2.bin ]; then
        ./build_atf.sh ${BOARD}
    fi

    if [ ! -f ${WORKPWD}/${UBOOT_DIR}/u-boot.bin ]; then
        ./build_u-boot.sh ${BOARD}
    fi

    ./bootparameter ${WORKPWD}/${ATF_DIR}/build/${SOC}/${BUILDMODE}/bl2_with_dtb-smarc.bin bl2_bp.bin
    cat ${WORKPWD}/${ATF_DIR}/build/${SOC}/${BUILDMODE}/bl2_with_dtb-smarc.bin >> bl2_bp.bin

    objcopy -O srec --adjust-vma=0x00011E00 --srec-forceS3 -I binary bl2_bp.bin bl2_bp_${BOARD}.srec

    chmod 777 fiptool
    ./fiptool create --align 16 \
    --soc-fw ${WORKPWD}/${ATF_DIR}/build/${SOC}/${BUILDMODE}/bl31.bin \
    --fw-config ${WORKPWD}/board_info.txt \
    --nt-fw ${WORKPWD}/${UBOOT_DIR}/u-boot.bin \
    fip.bin
    ./fiptool info fip.bin

    objcopy -I binary -O srec --adjust-vma=0x0000 --srec-forceS3 fip.bin fip_${BOARD}.srec
}

set_board_id() {
    BOARD=$1
    case "${BOARD}" in
        v2h)     BOARD_ID="22" ;;
        v2l)     BOARD_ID="33" ;;
        rzpi)    BOARD_ID="44" ;;
        g2l)     BOARD_ID="55" ;;
        g2lc)    BOARD_ID="66" ;;
        g2ul)    BOARD_ID="77" ;;
        g2l100)  BOARD_ID="88" ;;
        *)       echo "Unknown board: $BOARD"; exit 1 ;;
    esac

    BOARD_INFO_FILE="board_info.txt"

    if [ ! -f "${BOARD_INFO_FILE}" ]; then
        {
            printf "$BOARD_ID\n"
            printf "#define BOARD_ID_RZV2H\t\t\t\t22\n"
            printf "#define BOARD_ID_RZV2L\t\t\t\t33\n"
            printf "#define BOARD_ID_RZPI\t\t\t\t44\n"
            printf "#define BOARD_ID_RZG2L\t\t\t\t55\n"
            printf "#define BOARD_ID_RZG2LC\t\t\t\t66\n"
            printf "#define BOARD_ID_RZG2UL\t\t\t\t77\n"
            printf "#define BOARD_ID_RZG2L100\t\t\t\t88\n"
        } > "${BOARD_INFO_FILE}"
    fi

    sed -i "1s/.*/$BOARD_ID/" "${BOARD_INFO_FILE}"
}

function main_process(){
    BOARD=$1
    validate_board "${BOARD}"
    cd ${WORKPWD}
    set_board_id $BOARD
    rm *.srec
    get_bootparameter
    check_extra_tools
    mk_bootimage ${BOARD}
}

#--start--------
# ./merge_ipl_file.sh v2h
# ./merge_ipl_file.sh v2l
# ./merge_ipl_file.sh rzpi
# ./merge_ipl_file.sh g2l
# ./merge_ipl_file.sh g2l100
main_process $*
exit
#---- end ------
