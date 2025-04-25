#!/bin/bash
source ./common.sh

log_info(){
    local string=$1
    echo -ne "\e[32m $string \e[0m\n"
}

get_bootparameter()
{
    cd ${WORKPWD}/
    #download extra tool code
    if [ ! -d ${BOOTPARAMETER_DIR} ];then
        mkdir ${BOOTPARAMETER_DIR}
        cd ${BOOTPARAMETER_DIR}
        wget https://raw.githubusercontent.com/renesas-rz/meta-rzg2/dunfell/rzg2l/recipes-bsp/firmware-pack/bootparameter/bootparameter.c
    fi
    cd ${WORKPWD}/
}

check_extra_tools()
{
    cd ${WORKPWD}
    if [ ! -x fiptool ];then
        make -C ${WORKPWD}/${ATF_DIR}/tools/fiptool/ fiptool
        cp -af ${WORKPWD}/${ATF_DIR}/tools/fiptool/fiptool ${WORKPWD}
        echo "copy fiptool "
    fi

    if [ ! -x bootparameter ];then
        cd ${WORKPWD}/${BOOTPARAMETER_DIR}
        gcc bootparameter.c -o bootparameter
        cp bootparameter ${WORKPWD}
        cd ${WORKPWD}/
        echo "copy bootparameter "
    fi
}

mk_bootimage()
{
    SOC_TYPE=$1
    cd ${WORKPWD}
    ## Set BUILDMODE
    BUILDMODE=release

    if [ "${SOC_TYPE}" == "v2h" ] ; then
        BOARD="v2h"
    elif [ "${SOC_TYPE}" == "v2l" ] ; then
        BOARD="v2l"
    elif [ "${SOC_TYPE}" == "rzpi" ] ; then
        BOARD="g2l"
    elif [ "${SOC_TYPE}" == "g2l" ] ; then
        BOARD="g2l"
    elif [ "${SOC_TYPE}" == "g2l100" ] ; then
        BOARD="g2l"
    else
        exit
    fi

    if [ ! -f ${WORKPWD}/${ATF_DIR}/build/${BOARD}/${BUILDMODE}/bl2.bin ]; then
        cd ${WORKPWD}
       ./build_atf.sh ${SOC_TYPE}
    fi

    if [ ! -f ${WORKPWD}/${UBOOT_DIR}/u-boot.bin ]; then
        cd ${WORKPWD}
       ./build_u-boot.sh ${SOC_TYPE}
    fi

    # Create bl2_bp.bin
    ./bootparameter ${WORKPWD}/${ATF_DIR}/build/${BOARD}/${BUILDMODE}/bl2.bin bl2_bp.bin
    cat ${WORKPWD}/${ATF_DIR}/build/${BOARD}/${BUILDMODE}/bl2.bin >> bl2_bp.bin

    # Convert to srec
    objcopy -O srec --adjust-vma=0x00011E00 --srec-forceS3 -I binary bl2_bp.bin bl2_bp_${SOC_TYPE}.srec

    # Create fip.bin
    # Address    Binary File Path
    # 0x44000000 trusted-firmware-a/build/g2l/release/bl31.bin
    # 0x44100000 board_info.txt
    # 0x48080000 uboot/u-boot.bin
    chmod 777 fiptool
    ./fiptool create --align 16 \
    --soc-fw ${WORKPWD}/${ATF_DIR}/build/${BOARD}/${BUILDMODE}/bl31.bin \
    --fw-config ${WORKPWD}/board_info.txt \
    --nt-fw ${WORKPWD}/${UBOOT_DIR}/u-boot.bin \
    fip.bin
    ./fiptool info fip.bin

    # Convert to srec
    objcopy -I binary -O srec --adjust-vma=0x0000 --srec-forceS3 fip.bin fip_${SOC_TYPE}.srec
    cd ${WORKPWD}
}

# Map board name to BOARD_ID
set_board_id() {
    case "$1" in
        v2h)     echo 22 ;BOARD_ID="22";;
        v2l)     echo 33 ;BOARD_ID="33";;
        rzpi)    echo 44 ;BOARD_ID="44";;
        g2l)     echo 55 ;BOARD_ID="55";;
        g2lc)    echo 66 ;BOARD_ID="66";;
        g2ul)    echo 77 ;BOARD_ID="77";;
        g2l100)  echo 88 ;BOARD_ID="88";;
        *)       echo "Unknown board: $1"; exit 1 ;;
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

    # Replace the first line in board_info.txt with the BOARD_ID
    sed -i "1s/.*/$BOARD_ID/" board_info.txt
}

# Build all the components for a specific SoC type
function main_process(){
    SOC_TYPE=$1
    validate_soc_type "${SOC_TYPE}"

    cd ${WORKPWD}
    set_board_id $SOC_TYPE
    rm *.srec
    get_bootparameter
    check_extra_tools
    mk_bootimage ${SOC_TYPE}
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
