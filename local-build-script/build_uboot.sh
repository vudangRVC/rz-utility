#!/bin/bash

source ./config.ini

# Check Linux Kernel location
if [ -z "${UBOOT_DIR}" ]; then
        echo "There is no U-Boot source at ${UBOOT_DIR} or it does not set properly at config.ini file."
        echo "Please recheck your setup"
        exit 1
fi

mk_u-boot()
{
    SOC_TYPE=$1
    cd ${WORKPWD}/${UBOOT_DIR}/
    unset CFLAGS CPPFLAGS CXXFLAGS LDFLAGS
    make clean
    make distclean
    if [ "${SOC_TYPE}" == "v2l" ] ; then
        make smarc-rzv2l_defconfig
    elif [ "${SOC_TYPE}" == "rzpi" ] ; then
        make smarc-rzv2l_defconfig
    else
        make common_defconfig
    fi
    make -j12
    [ $? -ne 0 ] && log_error "Failed in ${UBOOT_DIR} ..." && exit
}

# Main U-Boot build
echo "Starting the U-Boot at ${UBOOT_DIR}"
if [ -z "${1}" ]; then
        exit 1
else
        cd "${UBOOT_DIR}" || exit 1

        case ${1} in
                'clean')
                        mk_clean
                        ;;
                'distclean')
                        mk_distclean
                        ;;
                'image')
                        mk_image
                        ;;
                'full-image')
                        mk_full_image
                        ;;
        esac

        exit 0
fi