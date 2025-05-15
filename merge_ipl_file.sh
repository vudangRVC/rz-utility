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
        cd ${WORKPWD}/${ATF_DIR}
        echo "copy bootparameter "
    fi
}

mk_bptool()
{
    # cd ${WORKPWD}/${ATF_DIR}/tools/renesas/rz_boot_param
    cd ${WORKPWD}/${ATF_DIR}/tools/renesas/rz_boot_param
    env -i PATH="$PATH" make DEST_OFFSET_ADR=0x08103000 bptool
    ls
    cp bptool ${WORKPWD}
    echo "copy bptool to ${WORKPWD}"
}

mk_bootimage_v2h()
{
    BOARD=$1
    cd ${WORKPWD}

    ## BUILDMODE=debug
    BUILDMODE=release

    # Create bl2_bp.bin esd
    ./bptool ${WORKPWD}/${ATF_DIR}/build/${BOARD}/${BUILDMODE}/bl2.bin bp.bin 0x08103000 esd
    cat bp.bin ${WORKPWD}/${ATF_DIR}/build/${BOARD}/${BUILDMODE}/bl2.bin > bl2_bp_esd.bin
    objcopy -I binary -O srec --adjust-vma=0x08101E00 --srec-forceS3 bl2_bp_esd.bin bl2_bp_esd_${BOARD}.srec
    mv -f bl2_bp_esd.bin bl2_bp_esd_${BOARD}.bin

    # Create bl2_bp.bin spi
    # ./bptool ${WORKPWD}/${ATF_DIR}/build/${BOARD}/${BUILDMODE}/bl2.bin bp.bin 0x08103000 spi
    # cat bp.bin ${WORKPWD}/${ATF_DIR}/build/${BOARD}/${BUILDMODE}/bl2.bin > bl2_bp_spi.bin
    # objcopy -I binary -O srec --adjust-vma=0x08101E00 --srec-forceS3 bl2_bp_spi.bin bl2_bp_spi_${BOARD}.srec

    # # Create bl2_bp.bin mmc
    # ./bptool ${WORKPWD}/${ATF_DIR}/build/${BOARD}/${BUILDMODE}/bl2.bin bp.bin 0x08103000 mmc
    # cat bp.bin ${WORKPWD}/${ATF_DIR}/build/${BOARD}/${BUILDMODE}/bl2.bin > bl2_bp_mmc.bin
    # objcopy -I binary -O srec --adjust-vma=0x08101E00 --srec-forceS3 bl2_bp_mmc.bin ${WORKPWD}/bl2_bp_mmc_${BOARD}.srec

    # Create fip.bin normal
    ./fiptool create --align 16 --soc-fw ${WORKPWD}/${ATF_DIR}/build/${BOARD}/${BUILDMODE}/bl31.bin \
        --nt-fw ${WORKPWD}/${UBOOT_DIR}/u-boot.bin fip.bin
    ./fiptool info fip.bin
    cp fip.bin ${WORKPWD}/fip_${BOARD}.bin
    objcopy -I binary -O srec --adjust-vma=0x44000000 --srec-forceS3 fip.bin ${WORKPWD}/fip_${BOARD}.srec
    rm fip.bin bp.bin
    cd ${WORKPWD}
}

mk_bootimage()
{
    BOARD=$1
    cd ${WORKPWD}
    BUILDMODE=release

    if [ "${BOARD}" == "v2h" ]; then
        SOC="v2h"
        mk_bptool
        mk_bootimage_v2h ${BOARD}
        exit 0
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

    ./bootparameter ${WORKPWD}/${ATF_DIR}/build/${SOC}/${BUILDMODE}/bl2.bin bl2_bp.bin
    cat ${WORKPWD}/${ATF_DIR}/build/${SOC}/${BUILDMODE}/bl2.bin >> bl2_bp.bin

    objcopy -O srec --adjust-vma=0x00011E00 --srec-forceS3 -I binary bl2_bp.bin bl2_bp_${BOARD}.srec

    chmod 777 fiptool
    ./fiptool create --align 16 \
    --soc-fw ${WORKPWD}/${ATF_DIR}/build/${SOC}/${BUILDMODE}/bl31.bin \
    --nt-fw ${WORKPWD}/${UBOOT_DIR}/u-boot.bin \
    fip.bin
    ./fiptool info fip.bin

    objcopy -I binary -O srec --adjust-vma=0x0000 --srec-forceS3 fip.bin fip_${BOARD}.srec
}

function main_process(){
    BOARD=$1
    validate_board "${BOARD}"
    cd ${WORKPWD}
    rm *.srec 
    rm *.bin
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
