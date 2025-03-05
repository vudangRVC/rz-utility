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
UBOOT_DIR="u-boot"
TFA_DIR="trusted-firmware-a"

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

check_extra_tools()
{
    cd ${WORKPWD}/${TFA_DIR}/
    if [ ! -x fiptool ];then
        make -C tools/fiptool/ fiptool
        cp -af tools/fiptool/fiptool ./
        echo "copy fiptool "
    fi

    if [ ! -x bootparameter ];then
        cd ${WORKPWD}/bootparameter/
        gcc bootparameter.c -o bootparameter
        cd ${WORKPWD}/
        cp -af bootparameter/bootparameter ${TFA_DIR}/
        echo "copy bootparameter "
    fi
}

# Merge u-boot and dtb
merge_u_boot_dtb()
{
	echo "======== Merge u-boot and dtb ========"
	cd ${WORKPWD}/${UBOOT_DIR}/
	cat u-boot-nodtb.bin arch/arm/dts/rz-common.dtb > u-boot-01.bin
	cat u-boot-01.bin arch/arm/dts/smarc-rzg2l.dtb > u-boot-02.bin
	cat u-boot-02.bin arch/arm/dts/smarc-rzv2l.dtb > u-boot.bin
	binwalk u-boot.bin
}


mk_bootimage()
{
    check_extra_tools
    cd ${WORKPWD}/${TFA_DIR}

    ## BUILDMODE=debug
    BUILDMODE=release
    # Create bl2_bp.bin
    ./bootparameter build/${SOC_TYPE}/${BUILDMODE}/bl2.bin bl2_bp.bin
    cat build/v2l/${BUILDMODE}/bl2.bin >> bl2_bp.bin

    # Create fip.bin
    cp ../${UBOOT_DIR}/u-boot.bin ./
    ./fiptool create --align 16 --soc-fw build/v2l/${BUILDMODE}/bl31.bin --nt-fw ./u-boot.bin fip.bin
    ./fiptool info fip.bin

    # Convert to srec
    objcopy -O srec --adjust-vma=0x00011E00 --srec-forceS3 -I binary bl2_bp.bin bl2_bp.srec
    objcopy -I binary -O srec --adjust-vma=0x0000 --srec-forceS3 fip.bin fip.srec
    cd ${WORKPWD}
}

function main_process(){
    SOC_TYPE=v2l
    cd ${WORKPWD}
    rm *.srec
    merge_u_boot_dtb
    mk_bootimage
    cp -f ${WORKPWD}/${TFA_DIR}/bl2_bp.srec ./bl2_bp_${SOC_TYPE}.srec
    cp -f ${WORKPWD}/${TFA_DIR}/fip.srec ./fip_${SOC_TYPE}.srec
    echo ""
    echo "---Finished--- the boot image as follow:"
    log_info bl2_bp_${SOC_TYPE}.srec
    log_info fip_${SOC_TYPE}.srec
}

#--start--------
main_process

exit
#---- end ------
