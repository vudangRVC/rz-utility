#!/bin/bash

source ./config.ini
source ./common.sh

# Check Flash-Writer location
if [ -z "${FLASH_WRITER_DIR}" ]; then
        echo "There is no U-Boot source at ${FLASH_WRITER_DIR} or it does not set properly at config.ini file."
        echo "Please recheck your setup"
        exit 1
fi

# Setup the build
flash_writer_setup() {
        case ${PLATFORM} in
                'RZG2L-SBC')
                        BOARD="RZG2L_SBC"
                        ;;
                'RZG2L-EVK')
                        BOARD="RZG2L_SMARC_PMIC"
                        ;;
                'RZV2L-EVK')
                        BOARD="RZV2L_SMARC_PMIC"
                        ;;
                'RZV2H-EVK')
                        BOARD=""
                        echo "The platform does not support yet. Cancelling the build" || exit 1
                        ;;
                *)
                        echo "The platform does not support. Please recheck your setup" || exit 1
                        ;;
        esac
}

mk_image() {
        flash_writer_setup
        make BOARD="${BOARD}" -j16
}

mk_clean() {
        make clean
}

# Main Flash-Writer build
echo "Starting the Flash-Writer build ${1} at ${FLASH_WRITER_DIR}"
cd "${FLASH_WRITER_DIR}" || exit 1

case ${1} in
        'clean')
                mk_clean
                ;;
        'all')
                mk_image
                ;;
        *)
                show_help
                ;;
esac

exit 0