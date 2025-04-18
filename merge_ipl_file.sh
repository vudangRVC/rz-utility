#!/bin/bash
#=============== TOOLCHAIN ========================================
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

#=============== MARCO ==============================================
WORKPWD=$(pwd)
UBOOT_DIR="uboot"
TFA_DIR="trusted-firmware-a"
BOOTPARAMETER_DIR="bootparameter_dir"

#=============== MAIN BODY NO NEED TO CHANGE =========================
help() {
bn=$(basename $0)
cat << EOF
usage :  $bn <option>
options:
  -h        display this help and exit
  -v2l       build boot image for the rzv2l board
  -clean    clean the build files for all projects
  -g        get all the code to build boot image
Example:
    ./$bn -rz
    ./$bn -clean
EOF
}

check_host_require(){
    # check required applications are installed
    command -v gcc > /dev/null
    if [ $? -eq 1 ]; then
        log_error "Command 'gcc' not found, but can be installed with:"
        log_info "sudo apt install gcc"
        exit
    fi

    dpkg -l | grep libssl-dev > /dev/null
    if [ ! $? -eq 0 ]; then
        log_error "Package 'libssl-dev' not found, but can be installed with:"
        log_info "sudo apt install libssl-dev"
        exit
    fi
    
    dpkg -l | grep bison > /dev/null
    if [ ! $? -eq 0 ]; then
        log_error "Package 'bison' not found, but can be installed with:"
        log_info "sudo apt install bison flex"
        exit
    fi

    command -v ${CROSS_COMPILE}gcc > /dev/null
    if [ $? -ne 0 ]; then
        log_error "ERROR: ${CROSS_COMPILE}gcc not found,"
        log_info "please install the toolchain first and export the enviroment like:"
        log_info "export PATH=\$PATH:your_toolchain_path"
        exit
    fi
}

log_error(){
    local string=$1
    echo -ne "\e[31m $string \e[0m\n"
}

log_info(){
    local string=$1
    echo -ne "\e[32m $string \e[0m\n"
}

mk_clean()
{
    cd ${WORKPWD}
    rm *.srec
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
        make -C ${WORKPWD}/${TFA_DIR}/tools/fiptool/ fiptool
        cp -af ${WORKPWD}/${TFA_DIR}/tools/fiptool/fiptool ${WORKPWD}
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
    check_extra_tools
    cd ${WORKPWD}

    ## BUILDMODE=debug
    BUILDMODE=release

    if [ "${SOC_TYPE}" == "v2l" ] ; then
        BOARD="v2l"
    elif [ "${SOC_TYPE}" == "rzpi" ] ; then
        BOARD="g2l"
    else
        BOARD="v2l"
    fi

    # Create bl2_bp.bin
    ./bootparameter ${WORKPWD}/${TFA_DIR}/build/${BOARD}/${BUILDMODE}/bl2.bin bl2_bp.bin
    cat ${WORKPWD}/${TFA_DIR}/build/${BOARD}/${BUILDMODE}/bl2.bin >> bl2_bp.bin
    # Convert to srec
    objcopy -O srec --adjust-vma=0x00011E00 --srec-forceS3 -I binary bl2_bp.bin bl2_bp_${SOC_TYPE}.srec

    # Create fip.bin
    # Address    Binary File Path
    # 0x44000000 trusted-firmware-a/build/g2l/release/bl31.bin
    # 0x44100000 board_info.txt
    # 0x44200000 uboot/arch/arm/dts/smarc-rzg2lc.dtb
    # 0x44300000 uboot/arch/arm/dts/smarc-rzv2l.dtb
    # 0x44400000 uboot/arch/arm/dts/rzpi.dtb
    # 0x44500000 uboot/arch/arm/dts/smarc-rzg2l.dtb
    # 0x48080000 uboot/u-boot.bin

    chmod 777 fiptool
    ./fiptool create --align 16 \
    --soc-fw ${WORKPWD}/${TFA_DIR}/build/${BOARD}/${BUILDMODE}/bl31.bin \
    --fw-config ${WORKPWD}/board_info.txt \
    --hw-config ${WORKPWD}/${UBOOT_DIR}/arch/arm/dts/smarc-rzg2lc.dtb \
    --soc-fw-config ${WORKPWD}/${UBOOT_DIR}/arch/arm/dts/smarc-rzv2l.dtb \
    --rmm-fw ${WORKPWD}/${UBOOT_DIR}/arch/arm/dts/rzpi.dtb \
    --nt-fw-config ${WORKPWD}/${UBOOT_DIR}/arch/arm/dts/smarc-rzg2l.dtb \
    --nt-fw ${WORKPWD}/${UBOOT_DIR}/u-boot.bin \
    fip.bin
   
    ./fiptool info fip.bin
    # Convert to srec
    objcopy -I binary -O srec --adjust-vma=0x0000 --srec-forceS3 fip.bin fip_${SOC_TYPE}.srec
    cd ${WORKPWD}
}

function main_process(){
    SOC_TYPE=$1
    cd ${WORKPWD}
    rm *.srec
    get_bootparameter
    mk_bootimage ${SOC_TYPE}
    echo ""
    echo "---Finished--- the boot image as follow:"
    log_info bl2_bp_${SOC_TYPE}.srec
    log_info fip_${SOC_TYPE}.srec
}

#--start--------
# ./merge_ipl_file.sh v2l
# ./merge_ipl_file.sh rzpi
main_process $*

exit
#---- end ------
