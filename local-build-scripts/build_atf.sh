#!/bin/bash

source ./config.ini
source ./common.sh

# Check ATF location
if [ -z "${ATF_DIR}" ]; then
        echo "There is no U-Boot source at ${ATF_DIR} or it does not set properly at config.ini file."
        echo "Please recheck your setup"
        exit 1
fi

# Setup the build
atf_setup() {
        unset CFLAGS LDFLAGS

        case ${PLATFORM} in
                'RZG2L-SBC')
                        PLAT="g2l"
                        BOARD="sbc_1"
                        ;;
                'RZG2L-EVK')
                        PLAT="g2l"
                        BOARD="smarc_pmic_2"
                        ;;
                'RZV2L-EVK')
                        PLAT="v2l"
                        BOARD="smarc_pmic_2"
                        ;;
                'RZV2H-EVK')
                        PLAT="v2h"
                        BOARD="evk_1"
                        ;;
                *)
                        echo "The platform does not support. Please recheck your setup" || exit 1
                        ;;
        esac        
}

mk_image() {
        local image=${1}
        atf_setup

        if [ "${ATF_MODE}" = "DEBUG" ]; then
            make -j16 PLAT="${PLAT}" BOARD="${BOARD}" DEBUG=1 "${image}"
        else
            make -j16 PLAT="${PLAT}" BOARD="${BOARD}" "${image}"
        fi
}

mk_clean() {
        make clean
}

mk_distclean() {
        make distclean
}

# Main ATF build
echo "Starting the ATF build ${1} at ${ATF_DIR}"
cd "${ATF_DIR}" || exit 1

case ${1} in
        'clean')
                mk_clean
                ;;
        'distclean')
                mk_distclean
                ;;
        'bl2')
                mk_image "${1}"
                ;;
        'bl31')
                mk_image "${1}"
                ;;
        'all')
                mk_image "${1}"
                ;;
        *)
                show_help
                ;;
esac

exit 0