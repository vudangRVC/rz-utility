#!/bin/bash
SDK_PATH=/opt/poky/3.1.14/environment-setup-aarch64-poky-linux

ARM_GCC_VERSION=SDK
if [ "${ARM_GCC_VERSION}" == "SDK" ] ; then
    ## sdk to build
    source $SDK_PATH
else
    ## gcc 8.3 default
    TOOLCHAIN_PATH=$HOME/toolchain/gcc-arm-8.3-2019.03-x86_64-aarch64-linux-gnu/bin
    export PATH=$TOOLCHAIN_PATH:$PATH
    export ARCH=arm64
    export CROSS_COMPILE=aarch64-linux-gnu-
fi

WORKPWD=$(pwd)

# u-boot
UBOOT_DIR="uboot"
UBOOT_GIT_URL="git@github.com:vudangRVC/u-boot-sst.git"
UBOOT_BRANCH="load-multi-dtb"

# ATF
TFA_DIR="trusted-firmware-a"
TFA_GIT_URL="git@github.com:vudangRVC/rz-atf-sst.git"
TFA_BRANCH="load-multi-dtb"
# TFA_COMMIT="40654149b5b8768aeaf8cebef9529a0be7118bbe"

#===============MAIN BODY NO NEED TO CHANGE=========================
help() {
bn=$(basename $0)
cat << EOF
usage :  $bn <option>
options:
  -h        display this help and exit
  -rzpi     build boot image for the Rzpi
  -clean    clean the build files for all projects
  -g        get all the code to build boot image
Example:
    ./$bn -rzpi
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
    make distclean -C ${UBOOT_DIR}/
    make distclean -C ${TFA_DIR}/
    rm ${TFA_DIR}/bl2_bp*
    rm ${TFA_DIR}/fip*
    rm ${TFA_DIR}/u-boot.bin
    rm *.srec
}

mk_getcode()
{
    cd ${WORKPWD}/
    #download uboot
    git clone $UBOOT_GIT_URL ${UBOOT_DIR}
    git -C ${UBOOT_DIR} checkout ${UBOOT_BRANCH}

    #download trusted-firmware-a
    git clone $TFA_GIT_URL ${TFA_DIR}
    git -C ${TFA_DIR} checkout ${TFA_BRANCH}

    #download extra tool code
    if [ ! -d bootparameter_dir ];then
        mkdir bootparameter_dir
        cd bootparameter_dir
        wget https://raw.githubusercontent.com/renesas-rz/meta-renesas/dunfell/rz/meta-rz-common/recipes-bsp/firmware-pack/bootparameter/bootparameter.c
    fi
    cd ${WORKPWD}/
}

mk_uboot()
{
    cd ${WORKPWD}/${UBOOT_DIR}/
    source $SDK_PATH
    unset LDFLAGS CFLAGS CPPFLAGS
    make clean
    make distclean

    if [ "${SOC_TYPE}" == "rzboard" ] ; then
        make rzboard_defconfig
    else
        make smarc-rzv2l_defconfig
    fi

    if [ "${SOC_TYPE}" == "rzpi" ] ; then
        make rzpi_defconfig
    else
        make defconfig
    fi

    make -j12
    [ $? -ne 0 ] && log_error "Failed in ${UBOOT_DIR} ..." && exit
}

mk_atf()
{
    cd ${WORKPWD}/${TFA_DIR}/
    case ${SOC_TYPE} in
        rzv2l)      echo "build atf for rzv2l"; make -j12 PLAT=v2l BOARD=smarc_pmic_2  bl2 bl31;;
        rzboard)    echo "build atf for rzboard"; make -j12 PLAT=v2l BOARD=rzboard  bl2 bl31;;
        rzpi)    echo "build atf for rzpi"; source $SDK_PATH; unset CFLAGS LDFLAGS; make clean; make distclean; make -j12 PLAT=g2l BOARD=sbc_1 all;;
    esac
    [ $? -ne 0 ] && log_error "Failed in ${TFA_DIR} ..." && exit
}

bl2_create()
{
    ## BUILDMODE=debug
    BUILDMODE=release
    
    # Create bl2_bp.bin
    cd ${WORKPWD}
    if [ ! -x ${WORKPWD}/${TFA_DIR}/build/g2l/${BUILDMODE}/bl2.bin ];then
        mk_atf
        cd ${WORKPWD}
    fi
    cp ${WORKPWD}/${TFA_DIR}/build/g2l/${BUILDMODE}/bl2.bin ${WORKPWD}

    if [ ! -f bootparameter ];then
        cd ${WORKPWD}/bootparameter_dir/
        gcc bootparameter.c -o bootparameter
        cp -af bootparameter ${WORKPWD}/
        echo "copy bootparameter "
        cd ${WORKPWD}
    fi

    ./bootparameter ${WORKPWD}/bl2.bin bl2_bp.bin
    cat ${WORKPWD}/bl2.bin >> bl2_bp.bin
    mv bl2_bp.bin bl2_bp-rzpi.bin
    objcopy -O srec --adjust-vma=0x00011E00 --srec-forceS3 -I binary bl2_bp-rzpi.bin bl2_bp-rzpi.srec
    rm bl2.bin
}

function fip_create(){
    cd ${WORKPWD}
    if [ ! -f ${WORKPWD}/fiptool ];then
        cd ${WORKPWD}/${TFA_DIR}/
        make -C tools/fiptool/ fiptool
        cp -af tools/fiptool/fiptool ${WORKPWD}
        echo "copy fiptool "
        cd ${WORKPWD}
    fi

    BUILDMODE=release
    if [ ! -f ${WORKPWD}/${TFA_DIR}/build/g2l/${BUILDMODE}/bl31.bin ]; then
        mk_atf
        cd ${WORKPWD}
    fi

    if [ ! -f ${WORKPWD}/${UBOOT_DIR}/u-boot.bin ]; then
        mk_uboot
        cd ${WORKPWD}
    fi

    if [ ! -d ${WORKPWD}/cm33 ]; then
        echo "Error: cm33 is not exist"
        exit
    fi

    chmod 777 fiptool
    ./fiptool create --align 16 \
    --soc-fw ${WORKPWD}/${TFA_DIR}/build/g2l/${BUILDMODE}/bl31.bin \
    --nt-fw-config ${WORKPWD}/${UBOOT_DIR}/arch/arm/dts/rzpi.dtb \
    --nt-fw ${WORKPWD}/${UBOOT_DIR}/u-boot.bin \
    --fw-config ${WORKPWD}/cm33/rzv2l_cm33_rpmsg_demo_secure_code.bin \
    --hw-config ${WORKPWD}/cm33/rzv2l_cm33_rpmsg_demo_non_secure_vector.bin \
    --soc-fw-config ${WORKPWD}/cm33/rzv2l_cm33_rpmsg_demo_secure_vector.bin \
    --rmm-fw ${WORKPWD}/${UBOOT_DIR}/arch/arm/dts/rzpi.dtb fip-rzpi.bin

    ./fiptool info fip-rzpi.bin

    objcopy -I binary -O srec --adjust-vma=0x00000000 --srec-forceS3 fip-rzpi.bin fip-rzpi.srec
    rm fip-rzpi.bin
}

function main_process(){
    SOC_TYPE="rzpi"
    echo "SOC_TYPE = $SOC_TYPE"

    [ $# -eq 0 ] && help && exit
    while [ $# -gt 0 ]; do
        case $1 in
            -h|--help) help; exit ;;
            -v|--version) echo "version 1.03" ; exit ;;
            -cl*)  mk_clean ; exit ;;
            -g)    mk_getcode ; exit ;;
            -rzpi) SOC_TYPE="rzpi"; echo ${SOC_TYPE};;
            *)  log_error "-- invalid option -- "; help; exit;;
        esac
        shift
    done

    check_host_require
    if [[ ! -d $UBOOT_DIR ]] || [[ ! -d $TFA_DIR ]] ;then
        log_error "Error: No found source code "
        log_info "use the follow command to download the all code:"
        log_info "./$(basename $0) -g"
        exit
    fi

    cd ${WORKPWD}
    mk_uboot
    mk_atf
    bl2_create
    fip_create
    echo ""
    echo "---Finished--- the boot image as follow:"
    log_info bl2_bp-${SOC_TYPE}.srec
    log_info fip-${SOC_TYPE}.srec
}

#--start--------
main_process $*

exit
#---- end ------
